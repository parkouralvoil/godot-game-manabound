extends VBoxContainer
class_name TeamHud

@export var selected_team_info: SelectedTeamInfo

@onready var char_1: Panel_Char = $Panel_Char1
@onready var char_2: Panel_Char = $Panel_Char2
@onready var char_3: Panel_Char = $Panel_Char3

@onready var char_box: Array[Panel_Char] = [char_1, char_2, char_3]
# move each new panel 75 y pos 

func initialize_hud() -> void: ## called by PlayerHolder
	var data_array: Array[CharacterResource] = selected_team_info.char_data_array
	for i in range(data_array.size()):
		var char_data: CharacterResource = data_array[i]
		char_box[i].initialize_info(char_data, i + 1)
		char_box[i].show()
