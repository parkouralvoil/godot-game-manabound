extends Control
class_name Panel_Char

# var tracked_character: Character = null ## this is only needed for retrieving stats, which 
# CharacterResource now contains
var tracked_char_resource: CharacterResource = null
var tracked_stats: CharacterStats = null

var color_selected := Color(0.18, 0.25, 0.14, 0.8)
var color_off_field := Color(0.14, 0.14, 0.14, 0.8)
var color_dead := Color(1, 0.3, 0.3, 0.8)

var old_hp: int

@onready var sprite_portrait: TextureRect = %CharPortrait
@onready var health: Label = %health
@onready var ammo: Label = %ammo
@onready var energy_bar: ProgressBar = %Energy
@onready var background: ColorRect = $background
@onready var line: ColorRect = $line

func initialize_info(character_data: CharacterResource, index: int) -> void:
	sprite_portrait.texture = character_data.sprite_portrait
	
	tracked_char_resource = character_data
	tracked_stats = character_data.stats
	old_hp = tracked_stats.hp
	
	tracked_char_resource.selected_changed.connect(_update_panel_status)
	tracked_stats.hp_changed.connect(_update_panel_status)


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
	var actual_string: String = format_string % [tracked_stats.hp, tracked_stats.max_hp]
	if old_hp < tracked_stats.hp: ## heal
		var t := create_tween()
		t.tween_property(health, "modulate", Color(1, 1, 1), 1).from(green)
	elif old_hp > tracked_stats.hp: ## got dmg
		var t := create_tween()
		t.tween_property(health, "modulate", Color(1, 1, 1), 1).from(red)
	health.text = actual_string
	old_hp = tracked_stats.hp


func update_ammo() -> void:
	var format_string: String = "Ammo: %d/%d"
	var actual_string: String = format_string % [tracked_stats.ammo,
		tracked_stats.max_ammo]
	if tracked_stats.hp <= 0:
		actual_string = "Downed"
	ammo.text = actual_string


func update_charge() -> void:
	# var yellow := Color(1, 1, 0)
	# var blue := Color(0.3, 0.3, 1)
	# var red := Color(1, 0.3, 0.3)
	# var gray := Color(0.9, 0.9, 0.9)
	# var elem := tracked_stats.element
	var charge := tracked_stats.charge
	var tier1_max_charge := tracked_stats.charge_threshold
	#print_debug(tier1_max_charge)
	energy_bar.value = (charge / tier1_max_charge) * energy_bar.max_value
	energy_bar.custom_minimum_size.x = clampf(tracked_stats.max_charge, 40, 80)
	
	#match elem:
			#CombatManager.Elements.LIGHTNING:
				#energy_bar.modulate = yellow
			#CombatManager.Elements.FIRE:
				#energy_bar.modulate = red
			#CombatManager.Elements.ICE:
				#energy_bar.modulate = blue
			#_:
				#energy_bar.modulate = yellow
	
	if charge >= tier1_max_charge: ## HACK
		energy_bar.self_modulate = Color(1, 1, 0)
	else:
		energy_bar.self_modulate = Color(1, 1, 1)


func _update_panel_status() -> void:
	if not tracked_stats:
		return
	
	if tracked_stats.hp <= 0:
		background.color = color_dead
		health.show()
		#ammo.show()
		energy_bar.hide()
	elif tracked_char_resource.selected:
		background.color = color_selected
		#ammo.show()
		energy_bar.show()
	else:
		background.color = color_off_field
		health.show()
		#ammo.show()
		energy_bar.show()
