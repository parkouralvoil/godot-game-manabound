extends Node2D
class_name DungeonHolder
"""
this handles the ff:
	- loading levels
	- stores DM's which have the packedscenes of the levels they have
"""

## TODO, aug 18:
"""
- move loading of level to DungeonHolder
- make presets customizable thru export (for testing)
- separate normal and elite enemy spawns
- make enemy spawns use "number of enemies" rather than spawn chance
- make enemy type selection RNG be fockin decent
- make cycle update both # of chests and enemy HP

NEXT
- make p.char_manager.selected_char_resources as a resource data

NEXT
- make chests drop runes
- make runes model
- make Stat Upgrade menu, thru button that appears when no enemy alive

NEXT
- make hub area where u can start lvl
"""

signal previous_level_cleaned_up
signal next_level_loaded(starting_pos: Vector2)

@export var current_DM: DungeonManager

## for now its Dungeon Manager -> Level Manager
## but later it might become Dungeon Manager -> Area Manager -> Level Manager

var current_level: LevelManager


@onready var main: Main = owner


func remove_previous_lvl() -> void:
	await main.fade_out()
	
	EventBus.clear_abilities.emit()
	if current_level:
		current_level.queue_free()
	await current_level.tree_exited
	previous_level_cleaned_up.emit()


func load_next_lvl() -> void: ## needs a parameter to see which map got chosen
	var lvl: LevelManager
	## TODO: add support for having multiple maps selectable
	assert(current_DM.NormalRooms.size() > 0, "Check the DM's NormalRooms export array")
	lvl = current_DM.NormalRooms[0].instantiate()
	lvl.room_preset = current_DM.chosen_preset
	lvl.level_cleared.connect(_on_level_cleared)
	
	add_child(lvl)
	## set level's enemy chances
	next_level_loaded.emit(lvl.starting_pos)


func _on_level_cleared() -> void:
	main.popup_indicator.show_lvl_cleared()
	await get_tree().create_timer(0.15).timeout
	EnemyAiManager.call_attract_orbs.emit()


func _select_normal_room() -> void:
	pass
