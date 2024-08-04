extends PanelContainer
class_name Panel_Char

@onready var sprite_portrait: TextureRect = $CharPortrait
@onready var char_name: Label = $HBoxContainer/VBoxContainer_info/Label_name
@onready var health: Label = $HBoxContainer/VBoxContainer_info/Label_health
@onready var ammo: Label = $HBoxContainer/VBoxContainer_info/Label_ammo
@onready var charge: Label = $HBoxContainer/VBoxContainer_info/Label_charge

var tracked_character: Character = null
var tracked_char_resource: CharacterResource = null


func initialize_info(character: CharacterResource, AM: Character, index: int) -> void:
	sprite_portrait.texture = character.sprite_portrait
	
	tracked_char_resource = character
	tracked_character = AM
	
	char_name.text = "[%s] %s" % [str(index), character.char_name]

func _process(_delta: float) -> void:
	if not tracked_character:
		return
	
	update_health()
	update_ammo()
	update_charge()
	
	if not tracked_char_resource.selected:
		modulate = Color(1, 1, 1, 0.5)
	else:
		modulate = Color(1, 1, 1, 1)
	
func update_health() -> void:
	var format_string: String = "Health: %s/%s"
	var actual_string: String = format_string % [str(tracked_character.stats.HP), 
		str(tracked_character.stats.MAX_HP)]
	health.text = actual_string

func update_ammo() -> void:
	var format_string: String = "Ammo: %d/%d"
	var actual_string: String = format_string % [tracked_character.stats.ammo,
		tracked_character.stats.MAX_AMMO]
	ammo.text = actual_string

func update_charge() -> void:
	var type: String = "Charge"
	match tracked_character.stats.charge_type:
		PlayerInfoResource.ChargeTypes.CHARGE:
			type = "Charge"
		PlayerInfoResource.ChargeTypes.ENERGY:
			type = "Energy"
		PlayerInfoResource.ChargeTypes.MANA:
			type = "Mana"
	
	var format_string: String = "%s: %d/%d"
	var actual_string: String = format_string % [type, 
		snapped(tracked_character.stats.charge, 1), 
		tracked_character.stats.MAX_CHARGE]
	charge.text = actual_string
	
	if tracked_character.stats.charge >= 100:
		charge.modulate = Color(1, 0.2, 0.2)
	elif tracked_character.stats.charge >= 50:
		charge.modulate = Color(1, 1, 0.2)
	elif tracked_character.stats.charge >= 1:
		charge.modulate = Color(1, 1, 1, 0.8)
	else:
		charge.modulate = Color(0.6, 0.6, 0.6, 0.8)
