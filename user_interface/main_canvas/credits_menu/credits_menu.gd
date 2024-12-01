extends Control
class_name CreditsMenu

signal exit_menu

func _on_close_pressed() -> void:
	exit_menu.emit()
