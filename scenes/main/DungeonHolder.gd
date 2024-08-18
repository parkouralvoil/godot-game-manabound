extends Node2D
class_name DungeonHolder
"""
this handles the ff:
	- loading levels
	- stores DM's which have the packedscenes of the levels they have
"""

## TODO, aug 18 now aug 19:
"""
NEXT
- make UI to choose which preset youll get
- might wanna make a subscription? for this

NEXT
- make chests drop runes
- make runes model
- make Stat Upgrade menu, thru button that appears when no enemy alive

NEXT
- make hub area where u can start lvl
"""

signal previous_level_cleaned_up
signal next_level_loaded(starting_pos: Vector2)

@export var dungeon_data: DungeonData

## for now its Dungeon Manager -> Level Manager
## but later it might become Dungeon Manager -> Area Manager -> Level Manager

var current_level: LevelManager


@onready var main: Main = owner


func initialize_dungeon() -> void:
	if dungeon_data:
		dungeon_data.start_cycle() ## sets cycle to 1
		dungeon_data.start_room() ## sets room_num to 1


func remove_previous_lvl() -> void:
	await main.fade_out()
	
	EventBus.clear_abilities.emit()
	if current_level:
		remove_child(current_level)
		current_level.queue_free()
	await get_tree().physics_frame
	current_level = null
	previous_level_cleaned_up.emit()


func load_next_lvl() -> void: ## needs a parameter to see which map got chosen
	## TODO: add support for having multiple maps selectable
	assert(dungeon_data.NormalRooms.size() > 0, "Check the dungeon data's NormalRooms export array")
	current_level = dungeon_data.NormalRooms[0].instantiate()
	current_level.room_preset = dungeon_data.chosen_preset
	current_level.level_cleared.connect(_on_level_cleared)
	current_level.exit_door_interacted.connect(_on_exit_door_interacted)
	
	add_child(current_level)
	## set level's enemy chances
	next_level_loaded.emit(current_level.starting_pos)


func _on_level_cleared() -> void:
	main.popup_indicator.show_lvl_cleared()
	await get_tree().create_timer(0.15).timeout
	EnemyAiManager.call_attract_orbs.emit()


func _on_exit_door_interacted() -> void:
	await remove_previous_lvl()
	dungeon_data.go_next_room() ## this updates room number, which can update cycle
	load_next_lvl()


func _select_normal_room() -> void:
	pass
