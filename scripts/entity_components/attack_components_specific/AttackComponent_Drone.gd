extends Node2D

var ProjectileScene: PackedScene = load("res://projectiles/enemy_projectiles/bullet_drone.tscn")

@onready var e: BaseEnemy = owner
@onready var t_firerate: Timer = $firerate
@onready var projecitle_pos: Marker2D = $projectile_origin

var bullet_color: Color = Color(1, 0.5, 0.5)

func _physics_process(_delta: float) -> void:
	if e.can_fire and t_firerate.is_stopped():
		t_firerate.start()
	elif !e.can_fire:
		t_firerate.stop()

func shoot(projectile: PackedScene, direction: Vector2) -> void:
	var pro_instance: Bullet = projectile.instantiate()
	if pro_instance:
		pro_instance.global_position = projecitle_pos.global_position
		
		pro_instance.speed = 120.0
		pro_instance.direction = direction
		pro_instance.rotation = direction.angle()
		pro_instance.damage = 1.0
		pro_instance.set_collision_mask_value(3, true)
		pro_instance.modulate = bullet_color
		pro_instance.max_distance = e.vision_range
		get_tree().root.add_child(pro_instance)
	elif pro_instance == null:
		print(projectile)

func _on_firerate_timeout() -> void:
	shoot(ProjectileScene, e.target_pos)
