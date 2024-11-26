extends VBoxContainer
class_name TeamHud

## given by PlayerHudCanvas
var player_info: PlayerInfoResource
var selected_team_info: SelectedTeamInfo

var max_team_size: int = 3
var team_size: int = 3

var _is_auto_aim: bool = true

@onready var label_aim: Label = $PanelContainer/AutoAim

@onready var char_1: Panel_Char = $Panel_Char1
@onready var char_2: Panel_Char = $Panel_Char2
@onready var char_3: Panel_Char = $Panel_Char3

@onready var char_box: Array[Panel_Char] = [char_1, char_2, char_3]
# move each new panel 75 y pos 

func initialize(new_player_info: PlayerInfoResource, 
		new_selected_team_info: SelectedTeamInfo) -> void:
	player_info = new_player_info
	selected_team_info = new_selected_team_info
	if selected_team_info:
		_initialize_team_hud()
	if player_info:
		_update_aim()
	

func _initialize_team_hud() -> void:
	var data_array: Array[CharacterResource] = selected_team_info.char_data_array
	team_size = data_array.size()
	for i in range(max_team_size):
		if i < team_size:
			var char_data: CharacterResource = data_array[i]
			char_box[i].initialize_info(char_data, i + 1)
			char_box[i].show()
		else:
			char_box[i].hide()

func _ready() -> void:
	EventBus.tutorial_team_restriction_set.connect(_hide_restricted_party)

func _process(_delta: float) -> void:
	if not player_info:
		return
	if _is_auto_aim != player_info.auto_aim:
		_update_aim()


func _hide_restricted_party(tutorial_level: int) -> void:
	for i in range(team_size):
		if i < tutorial_level:
			char_box[i].show()
		else:
			char_box[i].hide()


func _update_aim() -> void:
	_is_auto_aim = player_info.auto_aim
	var format_string: String = "Aim: %s"
	var actual_string: String = "aa"
	if not _is_auto_aim:
		actual_string = format_string % ["Manual"]
	else:
		actual_string = format_string % ["Auto"]
	label_aim.text = actual_string
