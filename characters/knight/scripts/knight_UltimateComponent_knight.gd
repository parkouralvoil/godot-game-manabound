extends Node2D
class_name Knight_UltimateComponent

@export var GrandBoltScene: PackedScene
@export var LightningBoltScene: PackedScene
@export var HomingMissileScene: PackedScene
@export var sfx_grand_ballista: AudioStream

## charge tier colors
var _red_weapon := Color(2, 1, 0.4)
var _yellow_weapon := Color(2, 2, 0.4)

@onready var character: Character = owner
@onready var PlayerInfo: PlayerInfoResource ## given by AM
@onready var AM: Knight_AbilityManager = get_parent()

#@onready var charge_particles: GPUParticles2D = $charge_particles

func _process(delta: float) -> void:
	#charge_particles.emitting = false
	if !character.enabled or character.is_dead:
		#decay_charge(delta)
		return
	
	#if PlayerInfo.input_ult:
		#PlayerInfo.ult_recoil = true
		##raise_charge(delta)
		#character.sprite_look_at(PlayerInfo.mouse_direction)
		#charge_particles.emitting = true
	#else:
		#charge_particles.emitting = false
		#if character.stats.charge >= 50:
			#spend_charge()
		#else:
			#decay_charge(delta)
		#character.wpn.modulate = Color(1, 1, 1)
	var s := character.stats
	if s.charge >= s.MAX_CHARGE / s.charge_tier:
		if s.charge >= s.MAX_CHARGE:
			character.wpn.modulate = _red_weapon
		else:
			character.wpn.modulate = _yellow_weapon
		if PlayerInfo.input_ult:
			character.sprite_look_at(PlayerInfo.mouse_direction)
		if Input.is_action_just_released("right_click"):
			if s.charge >= s.MAX_CHARGE and s.charge_tier == 2:
				spend_charge(2)
			else:
				spend_charge(1)
	else:
		character.wpn.modulate = Color(1, 1, 1)


func _physics_process(_delta: float) -> void:
	if !character.enabled or character.is_dead:
		return
	
	if PlayerInfo.input_ult:
		character.wpn.position = Vector2(3, 16) + Vector2(
				randf_range(-0.6, 0.6), randf_range(-0.9, 0.9))
	else:
		character.wpn.position = Vector2(3, 16)

func shoot(bullet: PackedScene, direction: Vector2, tier: int) -> void:
	assert(bullet, "missing ref")
	
	var bul_instance: Bullet = bullet.instantiate()
	bul_instance.global_position = self.global_position
	
	bul_instance.ep = character.stats.EP
	bul_instance.direction = direction
	bul_instance.rotation = direction.angle()
	bul_instance.set_collision_mask_value(4, true)
	bul_instance.max_distance = AM.ult_max_distance
	bul_instance.speed = AM.ult_bullet_speed# since scale makes this move slower
	bul_instance.scale = Vector2(1, 1)
	SoundPlayer.play_sound(sfx_grand_ballista, -4, 1.1)
	if tier == 2:
		bul_instance.piercing = true
		bul_instance.damage = AM.ult_damage_tier1
	else:
		bul_instance.damage = AM.ult_damage_tier1
	get_tree().root.add_child(bul_instance)

func shoot_extra(bullet: PackedScene, direction: Vector2) -> void:
	assert(bullet, "missing ref")
	
	var bul_instance: Bullet = bullet.instantiate()
	bul_instance.global_position = self.global_position
	
	bul_instance.ep = character.stats.EP
	bul_instance.direction = direction
	bul_instance.rotation = direction.angle()
	bul_instance.set_collision_mask_value(4, true)
	bul_instance.max_distance = AM.max_distance
	bul_instance.speed = AM.bullet_speed
	bul_instance.damage = AM.damage_lightning_bolt
	get_tree().root.add_child(bul_instance)


func spend_charge(tier: int) -> void:
	character.apply_player_cam_shake(1)
	
	if tier == 2:
		character.stats.charge = 0
		shoot(GrandBoltScene, PlayerInfo.mouse_direction, tier)
		var _angle: float
		_angle = -4 * PI/180
		shoot_extra(LightningBoltScene, PlayerInfo.mouse_direction.rotated(_angle))
		_angle = 0
		shoot_extra(LightningBoltScene, PlayerInfo.mouse_direction.rotated(_angle))
		_angle = 4 * PI/180
		shoot_extra(LightningBoltScene, PlayerInfo.mouse_direction.rotated(_angle))
		if AM.skill_ult_missile:
			shoot_missile(6)
	else:
		character.stats.charge = 0
		shoot(GrandBoltScene, PlayerInfo.mouse_direction, tier)
	
	if AM.skill_ult_missile:
		shoot_missile(3 * tier)


func shoot_missile(num_of_missiles: int) -> void:
	assert(HomingMissileScene, "missing export")
	var angle: float = 2*PI/num_of_missiles
	
	for i in range(num_of_missiles):
		var direction: Vector2 = Vector2(0, -1).rotated(angle * i)
		direction = direction.normalized()
		var missile_inst: Bullet = HomingMissileScene.instantiate()
		missile_inst.global_position = self.global_position
		
		missile_inst.ep = character.stats.EP
		missile_inst.direction = direction
		missile_inst.rotation = direction.angle()
		missile_inst.set_collision_mask_value(4, true)
		missile_inst.max_distance = AM.max_distance * 3
		missile_inst.damage = AM.damage_basic_bolt
		missile_inst.speed = AM.bullet_speed * 0.4
		#missile_inst.rotation_speed = 10
		get_tree().root.add_child(missile_inst)
