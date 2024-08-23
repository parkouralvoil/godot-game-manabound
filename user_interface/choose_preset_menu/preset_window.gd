extends PanelContainer
class_name PresetInfoWindow

signal info_window_chosen_preset(preset: RoomPreset) 
## kinda redundant to have to propagate this to choose_preset_menu
## since this doesnt have dungeon_data, or cuz its not on EventBus, but o well

var preset: RoomPreset = null:
	set(val):
		preset = val
		update_preset_info()
var pt: String = "- %s"

@onready var preset_label: Label = $MarginContainer/VBox/preset_name
@onready var info_1: Label = $MarginContainer/VBox/info1
@onready var info_2: Label = $MarginContainer/VBox/info2
@onready var info_3: Label = $MarginContainer/VBox/info3
@onready var select_button: Button = $MarginContainer/VBox/select


func update_preset_info() -> void:
	if preset:
		preset_label.text = preset.preset_name.capitalize()
		info_1.text = pt % preset.info1 if preset.info1 != "" else ""
		info_2.text = pt % preset.info2 if preset.info2 != "" else ""
		info_3.text = pt % preset.info3 if preset.info3 != "" else ""
		select_button.disabled = false
	else:
		select_button.disabled = true
	## if no preset, the preset menu just hides it


func _on_select_pressed() -> void:
	assert(preset, "%s is missing a preset yet somehow it was selected")
	info_window_chosen_preset.emit(preset)
