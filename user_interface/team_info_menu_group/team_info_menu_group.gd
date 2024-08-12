extends Control

signal exit_menu

@export var subscribe_playerholder_ui: SubscribePlayerHolder_To_UI

var color_stree := Color(0.25, 0.28, 0.37) #40475e
var color_char_stats := Color(0.18, 0.32, 0.26)

var current_index: int = 0

@onready var stree_menu: SkillTreeMenu = $SkillTreeMenu
@onready var char_stats_menu: CharacterStatusMenu = $CharacterStatusMenu
@onready var background: ColorRect = $Background

@onready var current_menu: Control = stree_menu
@onready var label_current_menu: Label = $CurrentMenu

@onready var char_1: Button = $MarginContainer/VBox/HBox1/Char1
@onready var char_2: Button = $MarginContainer/VBox/HBox1/Char2
@onready var char_3: Button = $MarginContainer/VBox/HBox1/Char3
@onready var char_buttons: Array[Button] = [char_1, char_2, char_3]


func _ready() -> void:
	visibility_changed.connect(_switch_sub_menu.bind(stree_menu))
	subscribe_playerholder_ui.data_updated.connect(_update_char_buttons)
	for b in char_buttons:
		b.hide()


func _switch_sub_menu(menu: Control) -> void:
	if menu == stree_menu:
		stree_menu.show()
		current_menu = stree_menu
		char_stats_menu.hide()
		background.color = color_stree
	elif menu == char_stats_menu:
		char_stats_menu.show()
		current_menu = char_stats_menu
		stree_menu.hide()
		background.color = color_char_stats


func _update_char_buttons(data: Array[CharacterResource]) -> void:
	char_stats_menu.initialize_menu(data)
	for i in range(3):
		if i < data.size():
			char_buttons[i].text = data[i].char_name
			char_buttons[i].show()
		else:
			char_buttons[i].text = "empty"
			char_buttons[i].hide()


func _on_char_1_pressed() -> void:
	label_current_menu.text = current_menu.show_specific_menu(0)
	current_index = 0


func _on_char_2_pressed() -> void:
	label_current_menu.text = current_menu.show_specific_menu(1)
	current_index = 1


func _on_char_3_pressed() -> void:
	label_current_menu.text = current_menu.show_specific_menu(2)
	current_index = 2


func _on_exit_button_pressed() -> void:
	exit_menu.emit()


func _on_skill_trees_pressed() -> void:
	_switch_sub_menu(stree_menu)
	label_current_menu.text = stree_menu.show_specific_menu(current_index)


func _on_character_stats_pressed() -> void:
	_switch_sub_menu(char_stats_menu)
	label_current_menu.text = char_stats_menu.show_specific_menu(current_index)
