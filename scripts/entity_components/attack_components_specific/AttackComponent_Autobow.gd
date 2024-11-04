extends Node2D
class_name AttackComponent_Autobow

var ProjectileScene: PackedScene = load("res://projectiles/bullet.tscn")

@onready var e: NormalEnemy = owner
@onready var t_firerate: Timer = $firerate
@onready var t_reload: Timer = $reload
@onready var t_first_shot: Timer = $before_first_shot

var bullet_color: Color = Color(1, 0.4, 0.2)

var last_aim_direction: Vector2 = Vector2.ZERO
var reload_reset: bool = false # only reverts back to false after superconduct clear

var max_ammo: int = 3
var ammo: int = max_ammo

func _ready() -> void:
	e.reload_time_changed.connect(update_reload)


func _update_vision() -> void:
	## handles vision
	e.target_pos = EnemyAiManager.player_position
	e.can_fire = (e.target_pos - global_position).length() < e.vision_range
	
	if e.can_fire:
		e.aim_direction = Vector2.ZERO.direction_to(e.target_pos 
			- self.global_position).normalized()


func _physics_process(_delta: float) -> void:
	_update_vision()
	if (e.can_fire 
	and ammo == max_ammo 
	and t_firerate.is_stopped() 
	and t_first_shot.is_stopped()):
		e.sprite_main.rotation = (e.aim_direction as Vector2).angle() - PI/2
		last_aim_direction = e.aim_direction
		t_first_shot.start() # this kicks off firerate which starts the firing cycle

func shoot(projectile: PackedScene, direction: Vector2) -> void:
	var pro_instance: Bullet = projectile.instantiate()
	if pro_instance:
		pro_instance.global_position = self.global_position
		
		pro_instance.speed = 180.0
		pro_instance.direction = direction
		pro_instance.rotation = direction.angle()
		pro_instance.damage = 1.0
		pro_instance.set_collision_mask_value(3, true) ## to look for player
		pro_instance.set_collision_layer_value(6, true) ## for parry
		pro_instance.modulate = bullet_color
		pro_instance.max_distance = e.vision_range
		get_tree().root.add_child(pro_instance)
	elif pro_instance == null:
		print(projectile)

func _on_firerate_timeout() -> void:
	if ammo > 0:
		burst_shoot()
		t_firerate.start()
	elif t_reload.is_stopped():
		t_reload.start()

func burst_shoot() -> void:
	ammo -= 1
	shoot(ProjectileScene, last_aim_direction)
	#shoot(ProjectileScene, last_aim_direction.rotated(PI/16) )
	#shoot(ProjectileScene, last_aim_direction.rotated(-PI/16) )

func update_reload(new_reload: float) -> void:
	t_reload.wait_time = new_reload

func _on_reload_timeout() -> void:
	ammo = max_ammo


func _on_before_first_shot_timeout() -> void:
	burst_shoot()
	t_firerate.start()
