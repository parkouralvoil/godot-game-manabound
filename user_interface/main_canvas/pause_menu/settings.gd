extends VBoxContainer
class_name Settings

## main tutorial: https://www.youtube.com/watch?v=EFnz9CgfJKI
## TODO: save settings

static var camera_shake: bool = true
static var inverted_hover: bool = false
static var show_fps: bool = false

signal settings_return_pressed()

@onready var checkbox_camera_shake: CheckBox = %camera2
@onready var checkbox_invert_mouse_distance: CheckBox = %invert2
@onready var checkbox_show_fps: CheckBox = %fps2

func _ready() -> void:
	var other_settings := ConfigFileHandler.load_other_settings()
	checkbox_camera_shake.button_pressed = other_settings.camera_shake
	checkbox_invert_mouse_distance.button_pressed = other_settings.invert_mouse_distance
	checkbox_show_fps.button_pressed = other_settings.show_fps

func _on_return_pressed() -> void:
	settings_return_pressed.emit()


func _on_camera_toggled(toggled_on: bool) -> void:
	camera_shake = toggled_on
	ConfigFileHandler.save_other_settings("camera_shake", toggled_on)


func _on_invert_2_toggled(toggled_on: bool) -> void:
	inverted_hover = toggled_on
	ConfigFileHandler.save_other_settings("invert_mouse_distance", toggled_on)


func _on_fps_toggled(toggled_on: bool) -> void:
	show_fps = toggled_on
	ConfigFileHandler.save_other_settings("show_fps", toggled_on)
