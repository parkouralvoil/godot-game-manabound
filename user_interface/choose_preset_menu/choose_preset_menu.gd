extends Control
class_name ChoosePresetMenu

var dungeon_data: DungeonData = null

@onready var menu_manager: MenuManager = owner ## i need the pause functions here
@onready var preset_1: PresetInfoWindow = $CenterContainer/VBox/HBox/Preset1
@onready var separator: Control = $CenterContainer/VBox/HBox/Separator
@onready var preset_2: PresetInfoWindow = $CenterContainer/VBox/HBox/Preset2


func initialize_preset_window(data: DungeonData) -> void:
	dungeon_data = data
	dungeon_data.exit_door_interacted.connect(_distribute_preset_choices)
	dungeon_data.game_started.connect(_distribute_preset_choices)


func _ready() -> void:
	preset_1.info_window_chosen_preset.connect(_UI_preset_selected)
	preset_2.info_window_chosen_preset.connect(_UI_preset_selected)


func _distribute_preset_choices() -> void:
	var choices: Array[RoomPreset] = dungeon_data.get_preset_choices()
	if choices.size() == 2:
		preset_1.preset = choices[0]
		preset_2.preset = choices[1]
		separator.show()
		preset_2.show()
	elif choices.size() == 1:
		preset_1.preset = choices[0]
		preset_2.preset = null
		separator.hide()
		preset_2.hide()
	menu_manager.pause_game()
	show()


func _UI_preset_selected(preset: RoomPreset) -> void:
	if not dungeon_data:
		return
	dungeon_data.preset_selected.emit(preset)
	menu_manager.unpause_game()
	hide()
