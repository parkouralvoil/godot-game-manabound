extends Control
class_name Panel_Char

# var tracked_character: Character = null ## this is only needed for retrieving stats, which 
# CharacterResource now contains
var tracked_char_resource: CharacterResource = null
var tracked_stats: CharacterStats = null

var _energy_bar_light: Texture = preload("res://assets/sprite_UI/progress_bars/energy_bar_light.png")

var color_selected := Color.DARK_GOLDENROD
var color_off_field := Color.BLACK
var color_dead := Color.DARK_RED

var old_hp: int

var _min_energy_bar_size: float = 30
var _max_energy_bar_size: float = 100


@onready var sprite_portrait: TextureRect = %CharPortrait
@onready var health: Label = %health
@onready var _health_default_color := health.modulate
@onready var ammo: Label = %ammo
@onready var energy_bar: TextureProgressBar = %Energy

@onready var outline: NinePatchRect = $outline
@onready var background: NinePatchRect = $background

func initialize_info(character_data: CharacterResource) -> void:
	sprite_portrait.texture = character_data.sprite_portrait
	
	tracked_char_resource = character_data
	tracked_stats = character_data.stats
	old_hp = tracked_stats.hp
	
	tracked_char_resource.selected_changed.connect(_update_panel_status)
	tracked_stats.hp_changed.connect(_update_panel_status)
	tracked_stats.max_charge_changed.connect(_on_max_charge_changed)


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
		t.tween_property(health, "modulate", _health_default_color, 1).from(Color.WHITE)
	elif old_hp > tracked_stats.hp: ## got dmg
		var t := create_tween()
		t.tween_property(health, "modulate", _health_default_color, 1).from(red)
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
	var charge := tracked_stats.charge
	energy_bar.value = (charge / tracked_stats.max_charge) * energy_bar.max_value
	
	if charge >= tracked_stats.charge_threshold: ## HACK
		energy_bar.show()
		energy_bar.texture_over = _energy_bar_light
	else:
		energy_bar.show()
		energy_bar.texture_over = null

func _on_max_charge_changed(new_max: float) -> void:
	energy_bar.custom_minimum_size.x = clampf(new_max, _min_energy_bar_size, _max_energy_bar_size)


func _update_panel_status() -> void:
	if not tracked_stats:
		return
	
	if tracked_stats.hp <= 0:
		outline.modulate = color_off_field
		background.modulate = color_dead
	elif tracked_char_resource.selected:
		outline.modulate = color_selected
		background.modulate = Color.WHITE
	else:
		outline.modulate = color_off_field
		background.modulate = Color.WHITE
