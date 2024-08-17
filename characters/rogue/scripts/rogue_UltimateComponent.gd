extends Node2D
class_name Rogue_UltimateComponent

@export var FlameEruption: PackedScene

@onready var character: Character = owner
@onready var PlayerInfo: PlayerInfoResource
@onready var AM: Rogue_AbilityManager = get_parent()

@onready var t_buff: Timer = $buff_duration


func _process(_delta: float) -> void:
	if not character.enabled:
		return
	
	PlayerInfo.ult_recoil = false
	if character.stats.charge >= character.stats.MAX_CHARGE:
		if PlayerInfo.input_ult:
			character.sprite_look_at(PlayerInfo.mouse_direction)
			character.wpn_sprite.modulate = Color(2, 0.4, 0.4)
		if Input.is_action_just_released("right_click"): # this the best way
			spend_charge()
			character.wpn_sprite.modulate = Color(1, 1, 1)


func spawn_impact(dmg_impact: PackedScene) -> void:
	assert(dmg_impact, "missing rogue impact")
	var instance: DamageImpact = dmg_impact.instantiate()
	instance.ep = character.stats.EP
	instance.global_position = global_position
	instance.damage = AM.ult_dmg
	instance.element = CombatManager.Elements.FIRE
	instance.scale = Vector2(1, 1) * AM.ult_size
	instance.can_generate_extra_energy = AM.ult_extra_energy_enabled
	get_tree().root.add_child(instance)


func spend_charge() -> void:
	character.apply_player_cam_shake(1)
	if t_buff.is_stopped(): ## should not stack
		PlayerInfo.buff_raw_atk += AM.ult_atk_buff
	spawn_impact(FlameEruption)
	character.stats.charge = 0
	t_buff.start()
	character.set_player_velocity(Vector2.ZERO)


func _on_buff_duration_timeout() -> void:
	PlayerInfo.buff_raw_atk -= AM.ult_atk_buff
