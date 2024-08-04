extends VBoxContainer
class_name TeamHud

var char_manager: CharacterManager = null

@onready var char_1: Panel_Char = $Panel_Char1
@onready var char_2: Panel_Char = $Panel_Char2
@onready var char_3: Panel_Char = $Panel_Char3

@onready var char_box: Array[Panel_Char] = [char_1, char_2]#, char_3]
# move each new panel 75 y pos 

func initialize_hud(p: Player) -> void: ## called by PlayerHolder
	char_manager = p.char_manager
	for i in range(char_manager.selected_char_resource.size()):
		var character := char_manager.selected_char_resource[i]
		var AM := char_manager.stored_chars[i]
		char_box[i].initialize_info(character, AM, i + 1)
		char_box[i].show()
