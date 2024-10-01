extends PanelContainer
class_name Panel_Char

# var tracked_character: Character = null ## this is only needed for retrieving stats, which 
# CharacterResource now contains
var tracked_char_resource: CharacterResource = null
var tracked_stats: CharacterStats = null

var color_selected := Color(1, 1, 1, 1)
var color_off_field := Color(1, 1, 1, 0.5)
var color_dead := Color(1, 0.3, 0.3, 0.8)

var old_hp: int

@onready var sprite_portrait: TextureRect = $CharPortrait
@onready var char_name: Label = $HBoxContainer/VBoxContainer_info/Label_name
@onready var health: Label = $HBoxContainer/VBoxContainer_info/Label_health
@onready var ammo: Label = $HBoxContainer/VBoxContainer_info/Label_ammo
@onready var charge: Label = $HBoxContainer/VBoxContainer_info/Label_charge

func initialize_info(character_data: CharacterResource, index: int) -> void:
	sprite_portrait.texture = character_data.sprite_portrait
	
	tracked_char_resource = character_data
	tracked_stats = character_data.stats
	old_hp = tracked_stats.HP
	
	tracked_char_resource.selected_changed.connect(_update_panel_status)
	tracked_stats.HP_changed.connect(_update_panel_status)
	
	char_name.text = "[%s] %s" % [str(index), character_data.char_name]


func _process(_delta: float) -> void:
	if not tracked_char_resource or not tracked_stats:
		push_warning("TeamHud's panel (%s) is missing tracked_char_resource/stats" % name)
		queue_free()
		return
	
	update_health()
	update_ammo()
	update_charge()


func update_health() -> void:
	var red := Color(1, 0.3, 0.3)
	var green := Color(0.3, 1, 0.3)
	
	var format_string: String = "HP: %d/%d"
	var actual_string: String = format_string % [tracked_stats.HP, tracked_stats.MAX_HP]
	if old_hp < tracked_stats.HP: ## heal
		var t := create_tween()
		t.tween_property(health, "modulate", Color(1, 1, 1), 1).from(green)
	elif old_hp > tracked_stats.HP: ## got dmg
		var t := create_tween()
		t.tween_property(health, "modulate", Color(1, 1, 1), 1).from(red)
	health.text = actual_string
	old_hp = tracked_stats.HP


func update_ammo() -> void:
	var format_string: String = "Ammo: %d/%d"
	var actual_string: String = format_string % [tracked_stats.ammo,
		tracked_stats.MAX_AMMO]
	if tracked_stats.HP <= 0:
		actual_string = "Downed"
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


func _update_panel_status() -> void:
	if not tracked_stats:
		return
	
	if tracked_stats.HP <= 0:
		modulate = color_dead
		health.show()
		ammo.show()
		charge.hide()
	elif tracked_char_resource.selected:
		modulate = color_selected
		ammo.show()
		charge.show()
	else:
		modulate = color_off_field
		health.show()
		ammo.show()
		charge.show()
