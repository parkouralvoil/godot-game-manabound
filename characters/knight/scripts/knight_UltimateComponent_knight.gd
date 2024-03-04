extends Node2D
class_name Knight_UltimateComponent

@export var GrandBoltScene: PackedScene

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

func shoot(bullet: PackedScene, direction: Vector2) -> void:
	assert(bullet, "missing ref")
	
	var bul_instance: Bullet = bullet.instantiate()
	bul_instance.global_position = self.global_position
	
	bul_instance.direction = direction
	bul_instance.rotation = direction.angle()
	bul_instance.set_collision_mask_value(4, true)
	bul_instance.max_distance = AM.ult_max_distance
	match charge_tier:
		2:
			bul_instance.scale = Vector2(1, 1)
			bul_instance.speed = AM.ult_bullet_speed
			bul_instance.piercing = true
			bul_instance.damage = AM.ult_damage_tier2 + 1
			print(AM.ult_damage_tier2 + 1)
		_:
			bul_instance.scale = Vector2(0.5, 0.5)
			bul_instance.speed = AM.ult_bullet_speed * 2 # since scale makes this move slower
			bul_instance.damage = AM.ult_damage_tier1
	get_tree().root.add_child(bul_instance)

func raise_charge(delta: float) -> void:
	character.charge = min(character.max_charge, 
		character.charge + character.charge_rate * delta)
	
	if character.charge == 100:
		charge_tier = 2
	elif character.charge >= 50:
		charge_tier = 1

func spend_charge() -> void:
	character.apply_player_cam_shake(charge_tier * 2)
	match charge_tier:
		0:
			pass
		1:
			shoot(GrandBoltScene, PlayerInfo.mouse_direction)
		_:
			shoot(GrandBoltScene, PlayerInfo.mouse_direction)
	character.charge = 0
	charge_tier = 0
