extends Control
class_name CharacterStatusMenu

## TODO, retrieving of stats is dependent on team selector
var char_resource_array: Array[CharacterResource]
## CharResource has stats, char_window, char_name, kit_name, and stree scene

@onready var char_window: CharacterWindow = $MarginContainer/HBox/CharacterWindow
@onready var stats_window: StatsWindow = $MarginContainer/HBox/StatsWindow
@onready var info_window: PanelContainer = $MarginContainer/HBox/InfoWindow

@onready var levelup_window: Control ## TODO, make level up mechanic and runes


func initialize_menu(arr: Array[CharacterResource]) -> void:
	char_resource_array = arr
	if arr.size() > 0:
		show_specific_menu(0)
	else:
		printerr("You passed empty Array[CharacterResource] to CharStatusMenu")


func show_specific_menu(index: int) -> String: ## return name of menu
	if index >= 0 and index < char_resource_array.size():
		char_window.tracked_char_resource = char_resource_array[index]
		stats_window.tracked_char_resource = char_resource_array[index]
	return "Character Stats"
