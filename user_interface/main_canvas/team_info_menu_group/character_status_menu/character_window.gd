extends PanelContainer
class_name CharacterWindow

var tracked_char_resource: CharacterResource = null:
	set(val):
		tracked_char_resource = val
		if val:
			update_window(val)

@onready var picture: TextureRect = $MarginContainer/VBox/SpritePicture
@onready var char_name: Label = $MarginContainer/VBox/char_name
@onready var element: Label = $MarginContainer/VBox/element
@onready var basic_atk: Label = $MarginContainer/VBox/basic_atk_name
@onready var ult: Label = $MarginContainer/VBox/ult_name


func update_window(cr: CharacterResource) -> void:
	picture.texture = cr.sprite_window
	char_name.text = "Name: %s" % cr.char_name
	element.text = _element_string(cr.stats.element)
	basic_atk.text = cr.basic_atk_name
	ult.text = cr.ult_name


func _element_string(elem: CombatManager.Elements) -> String:
	var format: String = "Element: %s"
	var elem_string: String = ""
	match elem:
		CombatManager.Elements.LIGHTNING:
			elem_string = "Lightning"
		CombatManager.Elements.ICE:
			elem_string = "Ice"
		CombatManager.Elements.FIRE:
			elem_string = "Fire"
	return format % elem_string
