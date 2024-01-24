extends Node2D

var ProjectileScene := load("res://scenes/projectiles/player_projectile_knight.tscn")
@export var p: Player

@onready var t_firerate: Timer = $firerate

func _process(delta):
	if Input.is_action_pressed("left_click") and t_firerate.is_stopped():
		shoot(ProjectileScene)
		t_firerate.start()

func shoot(projectile: PackedScene):
	var pro_instance := projectile.instantiate()
	if pro_instance:
		pro_instance.global_position = self.global_position
		
		pro_instance.direction = p.aim_direction
		pro_instance.rotation = p.aim_direction.angle()
		
		pro_instance.speed = 400.0
		pro_instance.lifespan = 0.4
		get_tree().root.add_child(pro_instance)
	elif pro_instance == null:
		print(projectile)
