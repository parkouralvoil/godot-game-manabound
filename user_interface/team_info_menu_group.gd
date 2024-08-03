extends Control

signal exit_menu

@onready var stree_menu: SkillTreeMenu = $SkillTreeMenu
@onready var stats_menu: Control

@onready var current_menu: Control = stree_menu
@onready var label_current_menu: Label = $MarginContainer/VBox/HBox2/CurrentMenu

func _ready() -> void:
	visibility_changed.connect(_switch_sub_menu.bind(stree_menu))


func _switch_sub_menu(menu: Control) -> void:
	if menu == stree_menu:
		stree_menu.show()
		current_menu = stree_menu
		#stats_menu.hide()


func _on_char_1_pressed() -> void:
	var menu_name: String = current_menu.show_specific_menu(0)
	label_current_menu.text = menu_name


func _on_char_2_pressed() -> void:
	var menu_name: String = current_menu.show_specific_menu(1)
	label_current_menu.text = menu_name


func _on_exit_button_pressed() -> void:
	exit_menu.emit()
