extends Node2D
class_name DungeonHolder
"""
this handles the ff:
	- loading levels of dungeon data
"""

@export_category("Main hub")
@export var main_hub_path: PackedScene

signal previous_level_cleaned_up
signal next_level_loaded(starting_pos: Vector2)

var dungeon_data: DungeonData ## given by main

## for now its Dungeon Manager -> Level Manager
## but later it might become Dungeon Manager -> Area Manager -> Level Manager

var main_hub: MainHub = null
var current_level: LevelManager

@onready var main: Main = owner

## load the main hub
func initialize_main_hub() -> void:
	main_hub = main_hub_path.instantiate()
	add_child(main_hub)
	next_level_loaded.emit(main_hub.starting_pos)
	dungeon_data.main_hub_loaded.emit()

func _on_returned_to_mainhub() -> void:
	EventBus.tutorial_team_restriction_set.emit(3)
	await remove_previous_lvl()
	initialize_main_hub()
	await main.fade_in()

## Initialize dungeon before loading the first level
func initialize_dungeon(selected_expedition: AreaData) -> void: ## called by main
	if dungeon_data:
		if not dungeon_data.preset_selected.is_connected(_on_preset_selected):
			dungeon_data.preset_selected.connect(_on_preset_selected)
		dungeon_data.start_cycle(selected_expedition) ## sets cycle to 1
	else:
		push_error("(%s): Dungeon data is null" % name)

func _ready() -> void:
	EventBus.level_cleared.connect(_on_level_cleared) # emitted by level
	EventBus.exit_door_interacted.connect(_on_exit_door_interacted) # emitted by exit door
	EventBus.returned_to_mainhub.connect(_on_returned_to_mainhub) # emitted by gameover
	EventBus.mainhub_departed.connect(initialize_dungeon) # emitted by signboard details


func remove_previous_lvl() -> void:
	await main.fade_out()
	await get_tree().create_timer(0.5).timeout ## to collect mana orbs
	EventBus.clear_abilities.emit()
	EnemyAiManager.reset_enemies()
	if current_level:
		remove_child(current_level)
		current_level.queue_free()
	await get_tree().physics_frame
	current_level = null
	previous_level_cleaned_up.emit()


func load_next_lvl() -> void: ## needs a parameter to see which map got chosen
	var lvl_scene: PackedScene = dungeon_data.get_level()
	assert(lvl_scene, "Array[NormalRooms] of AreaData has nothing")
	current_level = lvl_scene.instantiate()
	current_level.room_preset = dungeon_data.chosen_preset
	
	dungeon_data.state_in_combat = true
	
	add_child(current_level)
	## set level's enemy chances
	
	next_level_loaded.emit(current_level.starting_pos)


func _on_level_cleared(_msg: String) -> void:
	await get_tree().create_timer(0.15).timeout
	EnemyAiManager.call_attract_orbs.emit()
	dungeon_data.state_in_combat = false


func _on_exit_door_interacted() -> void:
	## show preset options
	if current_level.end_game_after_clear:
		dungeon_data.end_expedition()
	else:
		dungeon_data.exit_door_interacted.emit()


func _on_preset_selected(preset_from_UI: RoomPreset) -> void:
	await remove_previous_lvl()
	if has_node("MainHub"):
		remove_child(main_hub)
	dungeon_data.go_next_room(preset_from_UI) ## this updates room number, 
	## which can update cycle
	load_next_lvl()
	#print_debug("should be here now")
