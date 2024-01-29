extends Node2D

var ProjectileScene := load("res://scenes/projectiles/bullet.tscn")
@export var p: Player

@onready var t_firerate: Timer = $firerate

func _process(delta):
	if Input.is_action_pressed("left_click") and p.ammo_component.ammo > 0:
		p.is_firing = true
		sprite_look_at_aim()
		if t_firerate.is_stopped():
			shoot(ProjectileScene)
			t_firerate.start()
			p.velocity = Vector2.ZERO
		
	elif t_firerate.is_stopped():
		p.is_firing = false

func shoot(projectile: PackedScene):
	var pro_instance := projectile.instantiate()
	var direction = p.aim_direction
	p.camera_shake()
	p.ammo_component.ammo -= 1
	if pro_instance:
		pro_instance.global_position = self.global_position
		
		pro_instance.speed = 300.0
		pro_instance.direction = direction
		pro_instance.rotation = direction.angle()
		pro_instance.set_collision_mask_value(4, true)
		get_tree().root.add_child(pro_instance)
	elif pro_instance == null:
		print(projectile)

func sprite_look_at_aim():
	if p.aim_direction.x > 0:
		p.anim_sprite.scale.x = 1
	else:
		p.anim_sprite.scale.x = -1
