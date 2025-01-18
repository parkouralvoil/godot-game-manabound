extends Control
class_name GameInfoHud

## given by PlayerHudCanvas
var inventory: PlayerInventory:
	set(val):
		inventory = val
		#if inventory:
			#inventory.number_of_runes_changed.connect(_update_rune_number)
var dungeon_data: DungeonData: ## given by main
	set(val):
		dungeon_data = val
		if val:
			dungeon_data.combat_state_changed.connect(try_show_inventory)
			dungeon_data.main_hub_loaded.connect(_on_main_hub_loaded)

var boss_present: bool = false

"""
Room increases from 1 to 30
Cycle goes from 1 to 3
Level translate it as:
	Level (Cycle)-(Room)
	where room is restricted to 1 to 5, so room 6 is Level 2-1
"""
@onready var label_enemies: Label = %Enemies
@onready var label_orbs: Label = %ManaOrbs
#@onready var label_ap: Label = %AP

@onready var upgrade_stats_button: Button = %UpgradeStatsButton

## TODO: lmao i have two ways of doing initialize, either function or i just assign values xd
## ig in the longrun doing function is better since i can get the type hints from the function
func initialize(new_inventory: PlayerInventory, new_dungeon_data: DungeonData) -> void:
	inventory = new_inventory
	dungeon_data = new_dungeon_data


func _ready() -> void:
	EventBus.level_loaded.connect(_update_cycle_room)
	EventBus.level_loaded.connect(_on_game_started)
	EventBus.boss_fight_started.connect(_on_boss_fight_started)
	EventBus.boss_fight_ended.connect(_on_boss_fight_ended)


func _process(_delta: float) -> void:
	if not dungeon_data and not inventory:
		return
	label_orbs.text = str(inventory.mana_orbs)
	label_enemies.text = "Enemies left: %d" % EnemyAiManager.enemies_alive


func _on_boss_fight_started(boss_node: RailgunBoss) -> void:
	label_enemies.hide()
	label_orbs.hide()
	upgrade_stats_button.hide()

func _on_boss_fight_ended():
	label_orbs.show()
	try_show_inventory()

func try_show_inventory() -> void:
	if not dungeon_data.state_in_combat:
		label_enemies.hide()
		label_orbs.show()
		var can_use_rune: bool = (inventory.rune_ATK > 0 or
			inventory.rune_HP > 0 or
			inventory.rune_EP > 0 or
			inventory.rune_CHR > 0
		)
		upgrade_stats_button.visible = can_use_rune
	else:
		label_enemies.show()
		label_orbs.hide()
		upgrade_stats_button.hide()


func _update_cycle_room() -> void:
	pass
	#label_cycle_room.text = "Level: %d-%d" % [dungeon_data.current_area_index + 1, 
				#dungeon_data.current_room]


func _on_upgrade_stats_pressed() -> void:
	EventBus.upgrade_stats_pressed.emit()
	upgrade_stats_button.release_focus()


func _on_main_hub_loaded() -> void:
	label_enemies.hide()

func _on_game_started() -> void:
	if dungeon_data.chosen_preset:
		label_enemies.show()
