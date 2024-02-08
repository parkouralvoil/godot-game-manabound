extends Node2D

var GrandBoltScene: PackedScene = load("res://scenes/projectiles/grand_bolt/grand_bolt.tscn")

# this should have 2 charges
# by default, it only has 1 charge, strong single target bullet (like ac6 linear rifle), no piercing
# with upgrades:
# 2nd charge: piercing bullet, disappears on wall collision
# we can just have the explosion impact be "shockwave dealing minor dmg and additional lightning elem proc"

@onready var t_cd: Timer = $cooldown
@onready var AM: AbilityManager = get_parent()

var bullet_speed: float = 600

var charge_tier: int = 0

func _process(delta):
	if PlayerInfo.current_state == PlayerInfo.States.STANCE:
		raise_charge(delta)
		AM.sprite_look_at(PlayerInfo.mouse_direction)
	elif AM.charge != 0:
		spend_charge()

func shoot(projectile: PackedScene, direction: Vector2):
	var pro_instance := projectile.instantiate()
	if pro_instance:
		pro_instance.global_position = self.global_position
		
		pro_instance.direction = direction
		pro_instance.rotation = direction.angle()
		pro_instance.set_collision_mask_value(4, true)
		match charge_tier:
			2:
				pro_instance.piercing = true
				pro_instance.speed = bullet_speed
				pro_instance.damage = 25
			_:
				pro_instance.scale = Vector2(0.75, 0.75)
				pro_instance.speed = bullet_speed * 0.75
				pro_instance.damage = 30
		get_tree().root.add_child(pro_instance)
	elif pro_instance == null:
		print(projectile)

func raise_charge(delta):
	AM.charge = min(AM.max_charge, AM.charge + AM.charge_rate * delta)
	if AM.charge == AM.max_charge:
		charge_tier = 2
	elif AM.charge >= AM.max_charge/2:
		charge_tier = 1

func spend_charge():
	AM.apply_player_cam_shake(charge_tier * 2)
	match charge_tier:
		0:
			pass
		1:
			shoot(GrandBoltScene, PlayerInfo.mouse_direction)
		_:
			shoot(GrandBoltScene, PlayerInfo.mouse_direction)
			shoot(GrandBoltScene, PlayerInfo.mouse_direction.rotated(PI/10) )
			shoot(GrandBoltScene, PlayerInfo.mouse_direction.rotated(-PI/10) )
	AM.charge = 0
	charge_tier = 0
