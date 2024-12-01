extends HBoxContainer

@onready var checkbox_fullscreen: CheckBox = $VBox2/fullscreen
@onready var select_vsync: OptionButton = $VBox2/vsync

func _ready() -> void:
	var video_settings := ConfigFileHandler.load_video_settings()
	checkbox_fullscreen.button_pressed = video_settings.fullscreen
	if video_settings.vsync_index < 0 or video_settings.vsync_index > 3:
		select_vsync.value = video_settings.vsync_index


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	ConfigFileHandler.save_video_settings("fullscreen", toggled_on)


func _on_vsync_item_selected(index: int) -> void:
	if index < 0 or index > 3:
		return
	DisplayServer.window_set_vsync_mode(index)
	ConfigFileHandler.save_video_settings("vsync_index", index)
