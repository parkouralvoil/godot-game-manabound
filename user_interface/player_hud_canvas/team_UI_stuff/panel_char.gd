extends Control
class_name Panel_Char

# var tracked_character: Character = null ## this is only needed for retrieving stats, which 
# CharacterResource now contains
var tracked_char_resource: CharacterResource = null
var tracked_stats: CharacterStats = null

var color_selected := Color.DARK_GOLDENROD
var color_off_field := Color.DIM_GRAY
var color_dead := Color.DARK_RED

var old_hp: int

@onready var sprite_portrait: TextureRect = %CharPortrait
@onready var energy_bar: TextureProgressBar = %Energy
@onready var energy_ready: TextureRect = %EnergyReady
@onready var outline: TextureRect = %Outline

@onready var health: Label = %health
@onready var health_bar: TextureProgressBar = %HealthBar
@onready var _health_default_color := health.modulate

@onready var ammo: Label = %ammo
@onready var ammo_bar: TextureProgressBar = %AmmoBar

func initialize_info(character_data: CharacterResource) -> void:
	sprite_portrait.texture = character_data.sprite_portrait
	
	tracked_char_resource = character_data
	tracked_stats = character_data.stats
	old_hp = tracked_stats.hp
	
	tracked_char_resource.selected_changed.connect(_update_panel_status)
	tracked_stats.hp_changed.connect(_update_panel_status)
	#tracked_stats.max_charge_changed.connect(_on_max_charge_changed)


func _process(_delta: float) -> void:
	if not tracked_char_resource or not tracked_stats:
		push_warning("TeamHud's panel (%s) is missing tracked_char_resource/stats" % name)
		queue_free()
		return
	
	update_health()
	update_ammo()
	update_charge()


func update_health() -> void:
	var curr_hp: float = tracked_stats.hp
	var max_hp: float = tracked_stats.max_hp

	var red := Color(1, 0.3, 0.3)
	var green := Color(0.3, 1, 0.3)
	
	var format_string: String = "%d"
	var actual_string: String = format_string % [curr_hp]
	if old_hp < curr_hp: ## heal
		var t := create_tween()
		t.tween_property(health, "modulate", _health_default_color, 1).from(Color.WHITE)
	elif old_hp > curr_hp: ## got dmg
		var t := create_tween()
		t.tween_property(health, "modulate", _health_default_color, 1).from(red)
	health.text = actual_string
	health_bar.value = (curr_hp / max_hp) * health_bar.max_value
	old_hp = curr_hp

func update_ammo() -> void:
	var curr_ammo: float = tracked_stats.ammo
	var max_ammo: float = tracked_stats.max_ammo
	var format_string: String = "%d"
	var actual_string: String = format_string % [curr_ammo]
	if tracked_stats.hp <= 0:
		actual_string = "Downed"
	ammo.text = actual_string
	ammo_bar.value = (curr_ammo / max_ammo) * ammo_bar.max_value

func update_charge() -> void:
	var charge := tracked_stats.charge
	energy_bar.value = (charge / tracked_stats.max_charge) * energy_bar.max_value
	
	if charge >= tracked_stats.charge_threshold: ## HACK
		energy_ready.show()
	else:
		energy_ready.hide()

func _update_panel_status() -> void:
	if not tracked_stats:
		return
	
	if tracked_stats.hp <= 0:
		outline.self_modulate = color_dead
	elif tracked_char_resource.selected:
		outline.self_modulate = color_selected
	else:
		outline.self_modulate = color_off_field
