extends Node2D

var ProjectileScene := load("res://scenes/projectiles/bullet.tscn")

@export var entity: CharacterBody2D
@onready var t_firerate: Timer = $firerate
@onready var t_reload: Timer = $reload
@onready var t_first_shot: Timer = $before_first_shot

var last_aim_direction: Vector2 = Vector2.ZERO

func _physics_process(delta):
	if entity.can_fire and entity.ammo == entity.max_ammo and t_firerate.is_stopped() and t_first_shot.is_stopped():
		entity.sprite_main.rotation = entity.aim_direction.angle() - PI/2
		entity.ammo_container.rotation = entity.sprite_main.rotation
		last_aim_direction = entity.aim_direction
		t_first_shot.start()

func shoot(projectile: PackedScene, direction: Vector2):
	var pro_instance := projectile.instantiate()
	if pro_instance:
		pro_instance.global_position = self.global_position
		
		pro_instance.speed = 180.0
		pro_instance.direction = direction
		pro_instance.rotation = direction.angle()
		pro_instance.set_collision_mask_value(3, true)
		pro_instance.max_distance = entity.vision_range
		get_tree().root.add_child(pro_instance)
	elif pro_instance == null:
		print(projectile)

func _on_firerate_timeout():
	if entity.ammo > 0:
		burst_shoot()
		t_firerate.start()
	elif t_reload.is_stopped():
		t_reload.start()

func burst_shoot():
	entity.ammo -= 1
	shoot(ProjectileScene, last_aim_direction)
	#shoot(ProjectileScene, last_aim_direction.rotated(PI/16) )
	#shoot(ProjectileScene, last_aim_direction.rotated(-PI/16) )


func _on_reload_timeout():
	entity.ammo = entity.max_ammo


func _on_before_first_shot_timeout():
	burst_shoot()
	t_firerate.start()
