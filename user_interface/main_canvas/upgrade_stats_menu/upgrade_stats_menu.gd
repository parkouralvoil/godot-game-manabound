extends Control
class_name UpgradeStatsMenu

signal exit_menu

var char_resource_array: Array[CharacterResource]

@onready var window_array: Array[UpgradeStatsTab]
@onready var window_1: UpgradeStatsTab = $MarginContainer/TabContainer/UpgradeStatsTab
@onready var window_2: UpgradeStatsTab = $MarginContainer/TabContainer/UpgradeStatsTab2
@onready var window_3: UpgradeStatsTab = $MarginContainer/TabContainer/UpgradeStatsTab3

@onready var tab_container: TabContainer = $MarginContainer/TabContainer

func _ready() -> void:
	window_array = [window_1, window_2, window_3]


func initialize_stats_menu(_selected_team_info: SelectedTeamInfo,
		_inventory: PlayerInventory,
) -> void:
	char_resource_array = _selected_team_info.char_data_array
	for i in range(window_array.size()):
		if char_resource_array.size() > i:
			window_array[i].initialize_windows(_inventory, char_resource_array[i])
			window_array[i].name = " %s " % char_resource_array[i].char_name
			tab_container.set_tab_hidden(i, false)
		else:
			tab_container.set_tab_hidden(i, true)
	
	if char_resource_array.size() == 0:
		printerr("Upgrade Stats Menu: possible error in initialize_stats_menu()")


func _on_exit_button_pressed() -> void:
	exit_menu.emit()
