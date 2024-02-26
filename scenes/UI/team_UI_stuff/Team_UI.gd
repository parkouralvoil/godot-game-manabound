extends Control

@export var p: Player

@onready var char_1: Panel_Char = $Panel_Char1
@onready var char_2: Panel_Char = $Panel_Char2

@onready var char_box: Array[Panel_Char] = [char_1, char_2, null]
# move each new panel 75 y pos 

var char_manager: CharacterManager = null

func _ready() -> void:
	assert(p, "missing player")
	char_manager = p.char_manager
	for i in range(2):
		var character := char_manager.selected_char[i]
		var AM := char_manager.saved_AMs[i]
		char_box[i].initialize_info(character, AM, i + 1)
