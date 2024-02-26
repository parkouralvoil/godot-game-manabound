extends Panel
class_name Panel_Char

@onready var sprite_portrait: Sprite2D = $Sprite2D_portrait
@onready var char_name: Label = $VBoxContainer_info/Label_name
@onready var health: Label = $VBoxContainer_info/Label_health
@onready var ammo: Label = $VBoxContainer_info/Label_ammo
@onready var charge: Label = $VBoxContainer_info/Label_charge

var tracked_AM: AbilityManager = null
var tracked_character: CharacterResource = null


func initialize_info(character: CharacterResource, AM: AbilityManager, index: int) -> void:
	sprite_portrait.texture = character.sprite_portrait
	
	tracked_character = character
	tracked_AM = AM
	
	char_name.text = "%s) %s" % [str(index), character.char_name]

func _process(_delta: float) -> void:
	if tracked_AM:
		update_health()
		update_ammo()
		update_charge()
	visible = !tracked_character.selected
	
func update_health() -> void:
	var format_string: String = "Health: %s/%s"
	var actual_string: String = format_string % [str(tracked_AM.health), str(tracked_AM.max_health)]
	health.text = actual_string

func update_ammo() -> void:
	var format_string: String = "Ammo: %s/%s"
	var actual_string: String = format_string % [str(tracked_AM.ammo), str(tracked_AM.max_ammo)]
	ammo.text = actual_string

func update_charge() -> void:
	var format_string: String = "Charge: %s/%s"
	var actual_string: String = format_string % [str(snapped(tracked_AM.charge, 1)), str(tracked_AM.max_charge)]
	charge.text = actual_string
