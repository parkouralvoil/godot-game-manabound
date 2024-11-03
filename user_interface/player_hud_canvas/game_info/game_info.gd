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
			dungeon_data.combat_state_changed.connect(try_show_inventory)
			dungeon_data.main_hub_loaded.connect(_on_main_hub_loaded)

var boss_present: bool = false

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

@onready var rune_info: VBoxContainer = $VBox/InventoryInfo/MarginContainer/VBox/VBox
@onready var upgrade_stats_button: Button = $VBox/InventoryInfo/MarginContainer/VBox/VBox/UpgradeStatsButton

@onready var label_hp_rune: Label = $VBox/InventoryInfo/MarginContainer/VBox/VBox/GridContainer/num_hp
@onready var label_atk_rune: Label = $VBox/InventoryInfo/MarginContainer/VBox/VBox/GridContainer/num_atk
@onready var label_ep_rune: Label = $VBox/InventoryInfo/MarginContainer/VBox/VBox/GridContainer/num_ep
@onready var label_chr_rune: Label = $VBox/InventoryInfo/MarginContainer/VBox/VBox/GridContainer/num_chr

@onready var line_1: ColorRect = $VBox/MainInfo/MarginContainer/HBox/line
@onready var line_2: ColorRect = $VBox/OtherInfo/MarginContainer/HBox/line2

@onready var boss_info: MarginContainer = $BossInfo
@onready var boss_HP_bar: ProgressBar = %BossHP

## TODO: lmao i have two ways of doing initialize, either function or i just assign values xd
## ig in the longrun doing function is better since i can get the type hints from the function
func initialize(new_inventory: PlayerInventory, new_dungeon_data: DungeonData) -> void:
	inventory = new_inventory
	dungeon_data = new_dungeon_data


func _ready() -> void:
	EventBus.level_loaded.connect(_update_cycle_room)
	EventBus.level_loaded.connect(_on_game_started)
	EventBus.boss_fight_started.connect(_on_boss_fight_started)
	boss_info.hide()


func _process(_delta: float) -> void:
	if not dungeon_data and not inventory:
		return
	label_fps.text = "FPS: " + str(Engine.get_frames_per_second())
	label_orbs.text = "Orbs: " + str(inventory.mana_orbs)
	label_enemies.text = "Enemies left: %d" % BaseEnemy.enemies_alive


func _on_boss_fight_started(boss_node: Node2D) -> void:
	boss_node.boss_HP_bar = boss_HP_bar
	
	await get_tree().physics_frame ## this is HACK
	boss_info.show()
	label_enemies.hide()


func try_show_inventory() -> void:
	if not dungeon_data.state_in_combat:
		rune_info.show()
	else:
		rune_info.hide()


func _update_cycle_room() -> void:
	label_cycle_room.text = "Level: %d-%d" % [dungeon_data.current_cycle, 
				dungeon_data.current_room]
	if dungeon_data.chosen_preset:
		label_preset.text = "Room: %s" % dungeon_data.chosen_preset.preset_name


func _update_rune_number() -> void:
	var s: String = "x%d"
	label_hp_rune.text = s % inventory.rune_HP
	label_atk_rune.text = s % inventory.rune_ATK
	label_ep_rune.text = s % inventory.rune_EP
	label_chr_rune.text = s % inventory.rune_CHR


func _on_upgrade_stats_pressed() -> void:
	EventBus.upgrade_stats_pressed.emit()
	upgrade_stats_button.release_focus()


func _on_main_hub_loaded() -> void:
	rune_info.hide()
	line_1.hide()
	label_cycle_room.hide()
	line_2.hide()
	label_enemies.hide()
	label_preset.text = "Room: Hub"


func _on_game_started() -> void:
	if dungeon_data.chosen_preset:
		label_cycle_room.show()
		line_1.show()
		label_enemies.show()
		line_2.show()
