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

@onready var sprite_portrait: TextureRect = %CharPortrait
@onready var char_name: Label = $HBoxContainer/VBoxContainer_info/Label_name
@onready var health: Label = $HBoxContainer/VBoxContainer_info/Label_health
@onready var ammo: Label = $HBoxContainer/VBoxContainer_info/Label_ammo
@onready var energy_bar: TextureProgressBar = %Energy

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
	var yellow := Color(1, 1, 0)
	var blue := Color(0.3, 0.3, 1)
	var red := Color(1, 0.3, 0.3)
	var gray := Color(0.4, 0.5, 0.4)
	var elem := tracked_stats.element
	var charge := tracked_stats.charge
	var tier1_max_charge := tracked_stats.MAX_CHARGE / tracked_stats.charge_tier
	#print_debug(tier1_max_charge)
	energy_bar.value = (charge / tier1_max_charge) * energy_bar.max_value
	
	match elem:
			CombatManager.Elements.LIGHTNING:
				energy_bar.modulate = yellow
			CombatManager.Elements.FIRE:
				energy_bar.modulate = red
			CombatManager.Elements.ICE:
				energy_bar.modulate = blue
			_:
				energy_bar.modulate = yellow
	
	if charge >= tier1_max_charge:
		energy_bar.tint_progress = Color(1, 1, 1)
	else:
		energy_bar.tint_progress = gray


func _update_panel_status() -> void:
	if not tracked_stats:
		return
	
	if tracked_stats.HP <= 0:
		modulate = color_dead
		health.show()
		ammo.show()
		energy_bar.hide()
	elif tracked_char_resource.selected:
		modulate = color_selected
		ammo.show()
		energy_bar.show()
	else:
		modulate = color_off_field
		health.show()
		ammo.show()
		energy_bar.show()
