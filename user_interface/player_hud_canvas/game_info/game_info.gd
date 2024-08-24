extends Control
class_name GameInfoHud

## given by PlayerHudCanvas
var inventory: PlayerInventory:
	set(val):
		inventory = val
		if inventory:
			inventory.number_of_runes_changed.connect(_update_rune_number)
var dungeon_data: DungeonData: ## given by main
	set(val):
		dungeon_data = val
		if val:
			val.combat_state_changed.connect(try_show_inventory)

var current_lvl: int = 1

@onready var label_fps: Label = $VBox/OtherInfo/MarginContainer/HBox/FPS
@onready var label_enemies: Label = $VBox/OtherInfo/MarginContainer/HBox/Enemies

@onready var label_orbs: Label = $VBox/InventoryInfo/MarginContainer/VBox/ManaOrbs
@onready var label_cycle_room: Label = $VBox/MainInfo/MarginContainer/HBox/CycleRoom
"""
Room increases from 1 to 30
Cycle goes from 1 to 3
Level translate it as:
	Level (Cycle)-(Room)
	where room is restricted to 1 to 5, so room 6 is Level 2-1
"""
@onready var label_preset: Label = $VBox/MainInfo/MarginContainer/HBox/Preset

@onready var inventory_info: PanelContainer = $VBox/InventoryInfo
@onready var upgrade_stats_button: Button = $VBox/InventoryInfo/MarginContainer/VBox/UpgradeStatsButton

@onready var label_hp_rune: Label = $VBox/InventoryInfo/MarginContainer/VBox/GridContainer/num_hp
@onready var label_atk_rune: Label = $VBox/InventoryInfo/MarginContainer/VBox/GridContainer/num_atk
@onready var label_ep_rune: Label = $VBox/InventoryInfo/MarginContainer/VBox/GridContainer/num_ep
@onready var label_chr_rune: Label = $VBox/InventoryInfo/MarginContainer/VBox/GridContainer/num_chr

## TODO: lmao i have two ways of doing initialize, either function or i just assign values xd
## ig in the longrun doing function is better since i can get the type hints from the function
func initialize(new_inventory: PlayerInventory, new_dungeon_data: DungeonData) -> void:
	inventory = new_inventory
	dungeon_data = new_dungeon_data
	call_deferred("_update_cycle_room")


func _process(_delta: float) -> void:
	if not dungeon_data and not inventory:
		return
	label_fps.text = "FPS: " + str(Engine.get_frames_per_second())
	label_orbs.text = "Orbs: " + str(inventory.mana_orbs)
	label_enemies.text = "Enemies left: %d" % BaseEnemy.enemies_alive
	
	if current_lvl != dungeon_data.current_room: ## to reduce unnecessary computations
		_update_cycle_room()


func try_show_inventory() -> void:
	if not dungeon_data.state_in_combat:
		inventory_info.show()
	else:
		inventory_info.hide()


func _update_cycle_room() -> void:
	current_lvl = dungeon_data.current_room
	var offset: int = dungeon_data.cycle_room_progression
	var shown_lvl: int = current_lvl % offset
	if shown_lvl == 0:
		shown_lvl = offset
	
	label_cycle_room.text = "Level: %d-%d" % [dungeon_data.current_cycle, shown_lvl]
	label_preset.text = "Room: %s" %dungeon_data.chosen_preset.preset_name


func _update_rune_number() -> void:
	var s: String = "x%d"
	label_hp_rune.text = s % inventory.rune_HP
	label_atk_rune.text = s % inventory.rune_ATK
	label_ep_rune.text = s % inventory.rune_EP
	label_chr_rune.text = s % inventory.rune_CHR


func _on_upgrade_stats_pressed() -> void:
	EventBus.upgrade_stats_pressed.emit()
	upgrade_stats_button.release_focus()
