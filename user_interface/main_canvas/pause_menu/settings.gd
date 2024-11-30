extends VBoxContainer
class_name Settings

## main tutorial: https://www.youtube.com/watch?v=EFnz9CgfJKI
## TODO: save settings

static var camera_shake: bool = true
static var inverted_hover: bool = false

signal settings_return_pressed()


func _on_return_pressed() -> void:
	settings_return_pressed.emit()


func _on_camera_toggled(toggled_on: bool) -> void:
	camera_shake = toggled_on


func _on_invert_2_toggled(toggled_on: bool) -> void:
	inverted_hover = toggled_on
