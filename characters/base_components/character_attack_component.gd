extends Node2D
class_name Character_AttackComponent

@onready var character: Character = owner
@onready var PlayerInfo: PlayerInfoResource ## given by AM

var _firerate_modifier: float = 1 ## used by rogue

@onready var _t_firerate: Timer = $firerate
@onready var _t_recoil: Timer = $recoil

func _process(_delta: float) -> void:
	if not character.enabled or character.is_dead:
		return

	var can_shoot := _check_if_can_shoot()

	_update_recoil_and_look_at()
	
	if PlayerInfo.input_attack and can_shoot:
		if _t_firerate.is_stopped():
			_basic_atk()
			_update_firerate_and_apply_recoil()
			_t_firerate.start()
			_t_recoil.start()
			character.set_player_velocity(Vector2.ZERO)


func _update_recoil_and_look_at() -> void:
	if not _t_recoil.is_stopped():
		character.sprite_look_at(PlayerInfo.aim_direction)
		PlayerInfo.recoiling_from_basic_atk = true
	else:
		PlayerInfo.recoiling_from_basic_atk = false


func _set_bullet_properties(bullet: Bullet, properties: BulletProperties) -> void:
	## changes Bullet attributes
	bullet.ep 			= properties.ep
	bullet.max_distance = properties.max_distance
	bullet.speed 		= properties.speed
	bullet.damage 		= properties.final_damage
	bullet.set_collision_mask_value(4, true)	## to make it target enemies


func _basic_atk() -> void:
	# modify this
	pass

func _check_if_can_shoot() -> bool: ## can be modified if needed
	return (PlayerInfo.current_state != PlayerInfoResource.States.STANCE 
			and not PlayerInput.want_to_choose_boost_direction
			and character.stats.ammo > 0
	)

func _update_firerate_and_apply_recoil() -> void:
	_t_firerate.wait_time = (1 / character.stats.firerate) * _firerate_modifier
	if _t_firerate.wait_time > 0.2: 
		# semi
		_t_recoil.wait_time = 0.15
	else: 
		# auto
		_t_recoil.wait_time = 0.2
