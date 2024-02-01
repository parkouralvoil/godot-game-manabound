extends Node2D

var ProjectileScene := load("res://scenes/projectiles/bullet.tscn")

@export var entity: CharacterBody2D
@onready var t_firerate: Timer = $firerate
@onready var projecitle_pos: Marker2D = $projectile_origin

func _physics_process(delta):
	if entity.can_fire and t_firerate.is_stopped():
		t_firerate.start()
	elif !entity.can_fire:
		t_firerate.stop()

func shoot(projectile: PackedScene, direction: Vector2):
	var pro_instance := projectile.instantiate()
	if pro_instance:
		pro_instance.global_position = projecitle_pos.global_position
		
		pro_instance.speed = 180.0
		pro_instance.direction = direction
		pro_instance.rotation = direction.angle()
		pro_instance.set_collision_mask_value(3, true)
		pro_instance.max_distance = entity.vision_range
		get_tree().root.add_child(pro_instance)
	elif pro_instance == null:
		print(projectile)

func _on_firerate_timeout():
	shoot(ProjectileScene, entity.target_pos)
