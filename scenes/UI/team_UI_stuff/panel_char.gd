extends Panel
class_name Panel_Char

@onready var sprite_portrait: Sprite2D = $Sprite2D_portrait
@onready var char_name: Label = $VBoxContainer_info/Label_name
@onready var health: Label = $VBoxContainer_info/Label_health
@onready var ammo: Label = $VBoxContainer_info/Label_ammo
@onready var charge: Label = $VBoxContainer_info/Label_charge

var tracked_character: Character = null
var tracked_char_resource: CharacterResource = null


func initialize_info(character: CharacterResource, AM: Character, index: int) -> void:
	sprite_portrait.texture = character.sprite_portrait
	
	tracked_char_resource = character
	tracked_character = AM
	
	char_name.text = "[%s] %s" % [str(index), character.char_name]

func _process(_delta: float) -> void:
	if tracked_character:
		update_health()
		update_ammo()
		update_charge()
	if not tracked_char_resource.selected:
		modulate = Color(1, 1, 1, 0.7)
	else:
		modulate = Color(1, 1, 1, 1)
	
func update_health() -> void:
	var format_string: String = "Health: %s/%s"
	var actual_string: String = format_string % [str(tracked_character.health), 
		str(tracked_character.max_health)]
	health.text = actual_string

func update_ammo() -> void:
	var format_string: String = "Ammo: %d/%d"
	var actual_string: String = format_string % [tracked_character.ammo,
		tracked_character.max_ammo]
	ammo.text = actual_string

func update_charge() -> void:
	var type: String = "Charge"
	match tracked_character.charge_type:
		PlayerInfo.ChargeTypes.BURST:
			type = "Charge"
		PlayerInfo.ChargeTypes.ENERGY:
			pass
		PlayerInfo.ChargeTypes.PASSIVE:
			type = "Mana"
	
	var format_string: String = "%s: %d/%d"
	var actual_string: String = format_string % [type, 
		snapped(tracked_character.charge, 1), 
		tracked_character.max_charge]
	charge.text = actual_string
