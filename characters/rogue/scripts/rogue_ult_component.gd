extends Character_UltComponent
class_name Rogue_UltComponent

@export var FlameEruption: PackedScene
@export var sfx_ult: AudioStream

var _sword_default_color := Color(1, 1, 1)
var _sword_explosion_color := Color(2, 0.2, 0.2)

var flame_eruption_properties := ExplosionProperties.new()

var extra_energy_enabled := false
var ult_atk_buff: float

@onready var t_buff: Timer = $buff_duration

# region: inherited functions of Character_UltComponent
func _change_weapon_color_based_on_charge() -> void:
	if _charge >= _charge_threshold * 1:
		_character.wpn.modulate = _sword_explosion_color
	else:
		_character.wpn.modulate = _sword_default_color

func _activate_ult(tier: int) -> void:
	super(tier) ## very important
	if t_buff.is_stopped(): ## should not stack
		PlayerInfo.buff_raw_atk += ult_atk_buff
		print_debug("buff: ", PlayerInfo.buff_raw_atk)
	t_buff.start()
	
	await _play_animation()

	SoundPlayer.play_sound(sfx_ult, -15, 1.02)
	_spawn_impact(FlameEruption)
	
	_animation_finish()

func _mobile_activate_ult(tier: int) -> void:	## for mobile controls, no need to aim ult
	_t_ult_cooldown.start()
	await _t_ult_cooldown.timeout

	await _activate_ult(tier)
	PlayerInfo.ult_finished.emit(Vector2.ZERO)
# endregion
	

func _spawn_impact(dmg_impact: PackedScene) -> void:
	assert(dmg_impact, "missing rogue impact")
	var instance: DamageImpact = dmg_impact.instantiate()

	instance.ep 	=	flame_eruption_properties.ep
	instance.damage = flame_eruption_properties.final_damage
	instance.scale 	= Vector2(1, 1) * flame_eruption_properties.size

	instance.global_position = global_position
	instance.can_generate_extra_energy = extra_energy_enabled
	get_tree().root.add_child(instance)


func _play_animation() -> void:
	_character.apply_player_cam_shake(1)
	_character.set_player_velocity(Vector2.ZERO)
	_character.set_ult_animation(true)
	
	_character.arm.rotation_degrees = 0
	_character.wpn.rotation_degrees = 45
	
	var dur := 0.20
	var t := create_tween()
	t.set_ease(Tween.EASE_OUT)
	t.set_parallel()
	t.tween_property(_character.wpn, "modulate", 
			_sword_explosion_color, dur).from(_sword_default_color)
	#t.tween_property(_character.wpn, "rotation_degrees",
	#		135, dur).from(45).set_delay(0.1)
	t.tween_property(_character.arm, "rotation_degrees",
			360, dur).from(0)#.set_delay(0.1)
	await t.finished


func _animation_finish() -> void:
	_character.arm.rotation_degrees = 0
	_character.wpn.rotation_degrees = 135
	_character.wpn.modulate = _sword_default_color
	_character.set_ult_animation(false)


func _on_buff_duration_timeout() -> void:
	PlayerInfo.buff_raw_atk -= ult_atk_buff
