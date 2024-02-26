extends Node2D

@export var GrandBoltScene: PackedScene

@onready var AM: AbilityManager = get_parent()

var bullet_speed: float = 600
var damage: float = 20
var max_distance: float = 1000

var charge_tier: int = 0

func _process(delta: float) -> void:
	if !AM.enabled:
		AM.charge = 0
		return
	
	PlayerInfo.current_charge_type = PlayerInfo.ChargeTypes.BURST
	
	if PlayerInfo.current_state == PlayerInfo.States.STANCE:
		raise_charge(delta)
		AM.sprite_look_at(PlayerInfo.mouse_direction)
	elif AM.charge != 0:
		spend_charge()

func shoot(bullet: PackedScene, direction: Vector2) -> void:
	assert(bullet, "missing ref")
	
	var bul_instance: Bullet = bullet.instantiate()
	bul_instance.global_position = self.global_position
	
	bul_instance.direction = direction
	bul_instance.rotation = direction.angle()
	bul_instance.set_collision_mask_value(4, true)
	bul_instance.damage = damage
	bul_instance.max_distance = max_distance
	match charge_tier:
		2:
			bul_instance.scale = Vector2(1, 1)
			bul_instance.speed = bullet_speed
			bul_instance.piercing = true
		_:
			bul_instance.scale = Vector2(0.5, 0.5)
			bul_instance.speed = bullet_speed * 2 # since scale makes this move slower
	get_tree().root.add_child(bul_instance)

func raise_charge(delta: float) -> void:
	AM.charge = min(AM.max_charge, AM.charge + AM.charge_rate * delta)
	if AM.charge == AM.max_charge:
		charge_tier = 2
	elif AM.charge >= AM.max_charge/2:
		charge_tier = 1

func spend_charge() -> void:
	AM.apply_player_cam_shake(charge_tier * 2)
	match charge_tier:
		0:
			pass
		1:
			shoot(GrandBoltScene, PlayerInfo.mouse_direction)
		_:
			shoot(GrandBoltScene, PlayerInfo.mouse_direction)
	AM.charge = 0
	charge_tier = 0
