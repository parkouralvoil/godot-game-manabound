extends PanelContainer
class_name Panel_Char

@onready var sprite_portrait: TextureRect = $CharPortrait
@onready var char_name: Label = $HBoxContainer/VBoxContainer_info/Label_name
@onready var health: Label = $HBoxContainer/VBoxContainer_info/Label_health
@onready var ammo: Label = $HBoxContainer/VBoxContainer_info/Label_ammo
@onready var charge: Label = $HBoxContainer/VBoxContainer_info/Label_charge

# var tracked_character: Character = null ## this is only needed for retrieving stats, which 
# CharacterResource now contains
var tracked_char_resource: CharacterResource = null
var tracked_stats: CharacterStats = null


func initialize_info(character_data: CharacterResource, index: int) -> void:
	sprite_portrait.texture = character_data.sprite_portrait
	
	tracked_char_resource = character_data
	tracked_stats = character_data.stats
	
	char_name.text = "[%s] %s" % [str(index), character_data.char_name]


func _process(_delta: float) -> void:
	if not tracked_char_resource or not tracked_stats:
		push_warning("TeamHud's panel (%s) is missing tracked_char_resource/stats" % name)
		return
	
	update_health()
	update_ammo()
	update_charge()
	
	if not tracked_char_resource.selected:
		modulate = Color(1, 1, 1, 0.5)
	else:
		modulate = Color(1, 1, 1, 1)


func update_health() -> void:
	var format_string: String = "HP: %s/%s"
	var actual_string: String = format_string % [str(tracked_stats.HP), 
		str(tracked_stats.MAX_HP)]
	health.text = actual_string


func update_ammo() -> void:
	var format_string: String = "Ammo: %d/%d"
	var actual_string: String = format_string % [tracked_stats.ammo,
		tracked_stats.MAX_AMMO]
	ammo.text = actual_string


func update_charge() -> void:
	var type: String = "Charge"
	match tracked_stats.charge_type:
		PlayerInfoResource.ChargeTypes.CHARGE:
			type = "Charge"
		PlayerInfoResource.ChargeTypes.ENERGY:
			type = "Energy"
		PlayerInfoResource.ChargeTypes.MANA:
			type = "Mana"
	
	var format_string: String = "%s: %d/%d"
	var actual_string: String = format_string % [type, 
		snapped(tracked_stats.charge, 1), 
		tracked_stats.MAX_CHARGE]
	charge.text = actual_string
	
	if tracked_stats.charge >= 100:
		charge.modulate = Color(1, 0.2, 0.2)
	elif tracked_stats.charge >= 50:
		charge.modulate = Color(1, 1, 0.2)
	elif tracked_stats.charge >= 1:
		charge.modulate = Color(1, 1, 1, 0.8)
	else:
		charge.modulate = Color(0.6, 0.6, 0.6, 0.8)
