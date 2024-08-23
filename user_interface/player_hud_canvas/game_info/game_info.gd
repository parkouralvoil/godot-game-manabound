extends Control
class_name GameInfoHud

## given by PlayerHudCanvas
var inventory: PlayerInventory
var dungeon_data: DungeonData: ## given by main
	set(val):
		dungeon_data = val
		if val:
			val.combat_state_changed.connect(try_show_inventory)

var current_lvl: int = 1

@onready var label_fps: Label = $VBox/OtherInfo/MarginContainer/VBox/FPS
@onready var label_orbs: Label = $VBox/InventoryInfo/MarginContainer/VBox/ManaOrbs
@onready var label_cycle_room: Label = $VBox/MainInfo/MarginContainer/HBox/CycleRoom
@onready var label_preset: Label = $VBox/MainInfo/MarginContainer/HBox/Preset

@onready var inventory_info: PanelContainer = $VBox/InventoryInfo
@onready var upgrade_stats_button: Button = $VBox/InventoryInfo/MarginContainer/VBox/UpgradeStatsButton


func initialize(new_inventory: PlayerInventory, new_dungeon_data: DungeonData) -> void:
	inventory = new_inventory
	dungeon_data = new_dungeon_data
	call_deferred("_update_cycle_room")
"""
Room increases from 1 to 30
Cycle goes from 1 to 3
Level translate it as:
	Level (Cycle)-(Room)
	where room is restricted to 1 to 5, so room 6 is Level 2-1
"""

func _process(_delta: float) -> void:
	if not dungeon_data and not inventory:
		return
	label_fps.text = "FPS: " + str(Engine.get_frames_per_second())
	label_orbs.text = "Orbs: " + str(inventory.mana_orbs)
	
	if current_lvl != dungeon_data.current_room: ## to reduce unnecessary computations
		_update_cycle_room()


func _update_cycle_room() -> void:
	current_lvl = dungeon_data.current_room
	var offset: int = dungeon_data.cycle_room_progression
	var shown_lvl: int = current_lvl % offset
	if shown_lvl == 0:
		shown_lvl = offset
	
	label_cycle_room.text = "Level: %d-%d" % [dungeon_data.current_cycle, shown_lvl]
	label_preset.text = "Room: %s" %dungeon_data.chosen_preset.preset_name


func try_show_inventory() -> void:
	if not dungeon_data.state_in_combat:
		inventory_info.show()
	else:
		inventory_info.hide()


func _on_upgrade_stats_pressed() -> void:
	EventBus.upgrade_stats_pressed.emit()
	upgrade_stats_button.release_focus()
