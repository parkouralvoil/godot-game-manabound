extends Node2D
class_name Knight_UltimateComponent

@export var GrandBoltScene: PackedScene
@export var LightningBoltScene: PackedScene
@export var HomingMissileScene: PackedScene

@onready var character: Character = owner
@onready var AM: Knight_AbilityManager = get_parent()

var charge_tier: int = 0

func _process(delta: float) -> void:
	if !character.enabled:
		character.charge = 0
		return
	
	PlayerInfo.current_charge_type = PlayerInfo.ChargeTypes.BURST
	
	if PlayerInfo.current_state == PlayerInfo.States.STANCE:
		raise_charge(delta)
		character.sprite_look_at(PlayerInfo.mouse_direction)
	elif character.charge != 0:
		spend_charge()
		character.wpn_sprite.modulate = Color(1, 1, 1)

func shoot(bullet: PackedScene, direction: Vector2) -> void:
	assert(bullet, "missing ref")
	
	var bul_instance: Bullet = bullet.instantiate()
	bul_instance.global_position = self.global_position
	
	bul_instance.direction = direction
	bul_instance.rotation = direction.angle()
	bul_instance.set_collision_mask_value(4, true)
	bul_instance.max_distance = AM.ult_max_distance
	bul_instance.speed = AM.ult_bullet_speed * 1.5 # since scale makes this move slower
	match charge_tier:
		2:
			bul_instance.scale = Vector2(0.75, 0.75)
			#bul_instance.piercing = true
			bul_instance.damage = AM.ult_damage_tier1
		_:
			bul_instance.scale = Vector2(0.75, 0.75)
			bul_instance.damage = AM.ult_damage_tier1
	get_tree().root.add_child(bul_instance)

func shoot_extra(bullet: PackedScene, direction: Vector2) -> void:
	assert(bullet, "missing ref")
	
	var bul_instance: Bullet = bullet.instantiate()
	bul_instance.global_position = self.global_position
	
	bul_instance.direction = direction
	bul_instance.rotation = direction.angle()
	bul_instance.set_collision_mask_value(4, true)
	bul_instance.max_distance = AM.max_distance
	bul_instance.speed = AM.bullet_speed
	bul_instance.damage = AM.damage_lightning_bolt
	get_tree().root.add_child(bul_instance)

func raise_charge(delta: float) -> void:
	character.charge = min(character.max_charge, 
		character.charge + character.charge_rate * delta)
	
	if character.charge >= 100:
		charge_tier = 2
		character.wpn_sprite.modulate = Color(4, 1, 0.4)
	elif character.charge >= 50:
		charge_tier = 1
		character.wpn_sprite.modulate = Color(2, 2, 0.4)
	else:
		charge_tier = 0
		character.wpn_sprite.modulate = Color(1, 1, 1)
		
func spend_charge() -> void:
	character.apply_player_cam_shake(charge_tier * 2)
	match charge_tier:
		0:
			pass
		1:
			shoot(GrandBoltScene, PlayerInfo.mouse_direction)
			if AM.skill_ult_missile:
				shoot_missile(3)
		_:
			shoot(GrandBoltScene, PlayerInfo.mouse_direction)
			#var rng: RandomNumberGenerator = RandomNumberGenerator.new()
			var _angle: float
			_angle = -4 * PI/180
			shoot_extra(LightningBoltScene, PlayerInfo.mouse_direction.rotated(_angle))
			_angle = 0 #rng.randi_range(-4, 4) * PI/180
			shoot_extra(LightningBoltScene, PlayerInfo.mouse_direction.rotated(_angle))
			_angle = 4 * PI/180
			shoot_extra(LightningBoltScene, PlayerInfo.mouse_direction.rotated(_angle))
			if AM.skill_ult_missile:
				shoot_missile(6)
	character.charge = 0
	charge_tier = 0

func shoot_missile(num_of_missiles: int) -> void:
	assert(HomingMissileScene, "missing export")
	var angle: float = 2*PI/num_of_missiles
	
	for i in range(num_of_missiles):
		var direction: Vector2 = Vector2(0, -1).rotated(angle * i)
		direction = direction.normalized()
		var missile_inst: Bullet = HomingMissileScene.instantiate()
		missile_inst.global_position = self.global_position
		
		missile_inst.direction = direction
		missile_inst.rotation = direction.angle()
		missile_inst.set_collision_mask_value(4, true)
		missile_inst.max_distance = AM.max_distance * 3
		missile_inst.damage = AM.damage_basic_bolt
		missile_inst.speed = AM.bullet_speed * 0.4
		#missile_inst.rotation_speed = 10
		get_tree().root.add_child(missile_inst)
