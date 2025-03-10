extends Control
class_name PauseMenu

signal exit_menu

@onready var current_vbox: VBoxContainer = null
@onready var vbox_main: VBoxContainer = %VBox_main
@onready var vbox_confirm_base: VBoxContainer = %VBox_confirm_base
@onready var vbox_confirm_exit: VBoxContainer = %VBox_confirm_exit
@onready var vbox_settings: Settings = %Settings

@onready var return_to_base_button: Button = $Center2/VBox_main/ReturnToBase

## unnecessary, MenuManager pauses game when any menu is opened

func _ready() -> void:
	visibility_changed.connect(func() -> void: show_specific_vbox(vbox_main))
	vbox_settings.settings_return_pressed.connect(show_specific_vbox.bind(vbox_main))
	
	return_to_base_button.disabled = true
	EventBus.mainhub_departed.connect(_enable_returnToBase.unbind(1))
	EventBus.returned_to_mainhub.connect(_disable_returnToBase)


func show_specific_vbox(specific_vbox: VBoxContainer) -> void:
	if current_vbox:
		current_vbox.hide()
	current_vbox = specific_vbox
	specific_vbox.show()

func _disable_returnToBase() -> void:
	return_to_base_button.disabled = true

func _enable_returnToBase() -> void:
	return_to_base_button.disabled = false

func _on_resume_pressed() -> void:
	exit_menu.emit()


func _on_settings_pressed() -> void: ## TODO
	show_specific_vbox(vbox_settings)


func _on_return_to_base_pressed() -> void:
	show_specific_vbox(vbox_confirm_base)


func _on_exit_game_pressed() -> void:
	show_specific_vbox(vbox_confirm_exit)


func _on_confirm_return_pressed() -> void:
	## return to base
	EventBus.return_to_base_pressed.emit()
	exit_menu.emit()

func _on_cancel_return_pressed() -> void:
	show_specific_vbox(vbox_main)


func _on_confirm_exit_pressed() -> void:
	get_tree().quit()


func _on_cancel_exit_pressed() -> void:
	show_specific_vbox(vbox_main)
