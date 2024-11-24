extends Control
class_name ChoosePresetMenu

var dungeon_data: DungeonData = null
var selected_preset_choice_1: RoomPreset = null
var selected_preset_choice_2: RoomPreset = null

var done_distributing_choices: bool = false

@onready var menu_manager: MenuManager = owner ## i need the pause functions here
@onready var preset_choice_1: PresetInfoWindow = $CenterContainer/VBox/HBox/Preset1
@onready var separator: Control = $CenterContainer/VBox/HBox/Separator
@onready var preset_choice_2: PresetInfoWindow = $CenterContainer/VBox/HBox/Preset2


func initialize_preset_window(data: DungeonData) -> void:
	dungeon_data = data
	done_distributing_choices = false
	dungeon_data.exit_door_interacted.connect(_show_choices)


func _ready() -> void:
	preset_choice_1.info_window_chosen_preset.connect(_UI_preset_selected)
	preset_choice_2.info_window_chosen_preset.connect(_UI_preset_selected)


func _distribute_preset_choices() -> void:
	var choices: Array[RoomPreset] = dungeon_data.get_preset_choices()
	if choices.size() == 2:
		preset_choice_1.preset = choices[0]
		preset_choice_2.preset = choices[1]
		separator.show()
		preset_choice_2.show()
	elif choices.size() == 1:
		preset_choice_1.preset = choices[0]
		preset_choice_2.preset = null
		separator.hide()
		preset_choice_2.hide()

func _show_choices() -> void:
	if not done_distributing_choices:
		_distribute_preset_choices()
		done_distributing_choices = true
	menu_manager.pause_game()
	show()

func _UI_preset_selected(preset: RoomPreset) -> void:
	if not dungeon_data:
		printerr("No dungeon data on choose_preset_menu")
		return
	done_distributing_choices = false
	dungeon_data.preset_selected.emit(preset)
	menu_manager.unpause_game()
	hide()
