extends Node2D
class_name Rogue_UltimateComponent

@export var FlameEruption: PackedScene
@export var sfx_ult: AudioStream

var sword_default_color := Color(1, 1, 1)
var sword_explosion_color := Color(2, 0.2, 0.2)

@onready var character: Character = owner
@onready var PlayerInfo: PlayerInfoResource
@onready var AM: Rogue_AbilityManager = get_parent()

@onready var t_buff: Timer = $buff_duration


func _process(_delta: float) -> void:
	if not character.enabled:
		return
	#character.stats.charge = 100 ## HACK 
	if character.stats.charge >= character.stats.max_charge:
		if PlayerInfo.input_ult:
			character.sprite_look_at(PlayerInfo.mouse_direction)
		if Input.is_action_just_released("right_click") and not PlayerInfo.arm_animation_playing:
			character.set_ult_animation(true)
			spend_charge()


func spawn_impact(dmg_impact: PackedScene) -> void:
	assert(dmg_impact, "missing rogue impact")
	var instance: DamageImpact = dmg_impact.instantiate()
	instance.ep = character.stats.ep
	instance.global_position = global_position
	instance.damage = AM.ult_dmg
	instance.element = CombatManager.Elements.FIRE
	instance.scale = Vector2(1, 1) * AM.ult_size
	instance.can_generate_extra_energy = AM.ult_extra_energy_enabled
	get_tree().root.add_child(instance)


func spend_charge() -> void:
	if t_buff.is_stopped(): ## should not stack
		PlayerInfo.buff_raw_atk += AM.ult_atk_buff
		print_debug("buff: ", PlayerInfo.buff_raw_atk)
	t_buff.start()
	character.apply_player_cam_shake(1)
	character.set_player_velocity(Vector2.ZERO)
	character.set_ult_animation(true)
	
	character.arm.rotation_degrees = 0
	character.wpn.rotation_degrees = 45
	
	var dur := 0.22
	var t := create_tween()
	t.set_ease(Tween.EASE_OUT)
	t.set_parallel()
	t.tween_property(character.wpn, "modulate", 
			sword_explosion_color, dur).from(sword_default_color)
	#t.tween_property(character.wpn, "rotation_degrees",
	#		135, dur).from(45).set_delay(0.1)
	t.tween_property(character.arm, "rotation_degrees",
			360, dur).from(0)#.set_delay(0.1)
	await t.finished
	SoundPlayer.play_sound(sfx_ult, -15, 1.02)
	

	## why cant the ult just use its own arm???
	character.arm.rotation_degrees = 0
	character.wpn.rotation_degrees = 135
	character.wpn.modulate = sword_default_color
	spawn_impact(FlameEruption)
	character.stats.charge -= 50
	character.set_ult_animation(false)


func _on_buff_duration_timeout() -> void:
	PlayerInfo.buff_raw_atk -= AM.ult_atk_buff
