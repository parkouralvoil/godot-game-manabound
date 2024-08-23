extends Node2D
class_name DungeonHolder
"""
this handles the ff:
	- loading levels of dungeon data
"""

## TODO, aug 19:
"""
NEXT
- make chests drop runes
- make runes model
- make Stat Upgrade menu, thru button that appears when no enemy alive
- use spreadsheet to balance HP scaling and rune droprates

NEXT
- make hub area where u can start lvl
- make rest rooms where u can upgrade stree, appears every 5 lvls

LAST
- make death mechanic and revives
- make first boss fight
- make tutorials
- rogue sound effects
"""

signal previous_level_cleaned_up
signal next_level_loaded(starting_pos: Vector2)

var dungeon_data: DungeonData ## given by main

## for now its Dungeon Manager -> Level Manager
## but later it might become Dungeon Manager -> Area Manager -> Level Manager

var current_level: LevelManager


@onready var main: Main = owner

## Initialize dungeon before loading the first level
func initialize_dungeon() -> void: ## called by main
	if dungeon_data:
		dungeon_data.start_cycle() ## sets cycle to 1
		dungeon_data.start_room() ## sets room_num to 1
		dungeon_data.state_in_combat = true
		dungeon_data.preset_selected.connect(_on_preset_selected)
	else:
		push_error("(%s): Dungeon data is null" % name)


func _ready() -> void:
	EventBus.level_cleared.connect(_on_level_cleared)
	EventBus.exit_door_interacted.connect(_on_exit_door_interacted)


func remove_previous_lvl() -> void:
	await main.fade_out()
	await get_tree().create_timer(0.5).timeout ## to collect mana orbs
	EventBus.clear_abilities.emit()
	if current_level:
		remove_child(current_level)
		current_level.queue_free()
	await get_tree().physics_frame
	current_level = null
	previous_level_cleaned_up.emit()


func load_next_lvl() -> void: ## needs a parameter to see which map got chosen
	## TODO: implement selecting random maps
	assert(dungeon_data.NormalRooms.size() > 0, "Check the dungeon data's NormalRooms export array")
	
	## TODO: implement going to rest room
	current_level = dungeon_data.NormalRooms[0].instantiate()
	current_level.room_preset = dungeon_data.chosen_preset
	
	dungeon_data.state_in_combat = true
	
	add_child(current_level)
	## set level's enemy chances
	next_level_loaded.emit(current_level.starting_pos)


func _on_level_cleared() -> void:
	await get_tree().create_timer(0.15).timeout
	EnemyAiManager.call_attract_orbs.emit()
	dungeon_data.state_in_combat = false


func _on_exit_door_interacted() -> void:
	## show preset options
	dungeon_data.exit_door_interacted.emit()


func _on_preset_selected(preset_from_UI: RoomPreset) -> void:
	await remove_previous_lvl()
	
	dungeon_data.go_next_room(preset_from_UI) ## this updates room number, which can update cycle
	load_next_lvl()


func _select_normal_room() -> void:
	pass
