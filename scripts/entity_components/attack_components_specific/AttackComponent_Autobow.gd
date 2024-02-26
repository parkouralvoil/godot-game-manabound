extends Node2D

var ProjectileScene: PackedScene = load("res://scenes/projectiles/bullet.tscn")

@onready var e: BaseEnemy = owner
@onready var t_firerate: Timer = $firerate
@onready var t_reload: Timer = $reload
@onready var t_first_shot: Timer = $before_first_shot

@onready var rng := RandomNumberGenerator.new()

var last_aim_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	t_reload.wait_time = e.reload_time

func _process(_delta: float) -> void:
	t_reload.wait_time = e.reload_time	
	if e.can_fire and e.ammo == e.max_ammo and t_firerate.is_stopped() and t_first_shot.is_stopped():
		e.sprite_main.rotation = (e.aim_direction as Vector2).angle() - PI/2
		last_aim_direction = e.aim_direction
		t_first_shot.start()

func shoot(projectile: PackedScene, direction: Vector2) -> void:
	var pro_instance: Bullet = projectile.instantiate()
	if pro_instance:
		pro_instance.global_position = self.global_position
		
		pro_instance.speed = 180.0
		pro_instance.direction = direction
		pro_instance.rotation = direction.angle()
		pro_instance.damage = 1.0
		pro_instance.set_collision_mask_value(3, true) # to look for player
		pro_instance.modulate = e.bullet_color
		pro_instance.max_distance = e.vision_range
		get_tree().root.add_child(pro_instance)
	elif pro_instance == null:
		print(projectile)

func _on_firerate_timeout() -> void:
	if e.ammo > 0:
		burst_shoot()
		t_firerate.start()
	elif t_reload.is_stopped():
		t_reload.start()

func burst_shoot() -> void:
	e.ammo -= 1
	shoot(ProjectileScene, last_aim_direction)
	#shoot(ProjectileScene, last_aim_direction.rotated(PI/16) )
	#shoot(ProjectileScene, last_aim_direction.rotated(-PI/16) )


func _on_reload_timeout() -> void:
	e.ammo = e.max_ammo


func _on_before_first_shot_timeout() -> void:
	burst_shoot()
	t_firerate.start()
