extends Node2D
class_name EnemyAttackComponent_Machinegun

var ProjectileScene: PackedScene = load("res://projectiles/enemy_projectiles/bullet_machinegun.tscn")

@onready var e: BaseEnemy = owner
@onready var t_reload: Timer = $reload
@onready var t_first_shot: Timer = $before_first_shot
@onready var bullet_origin: Marker2D = $bullet_origin

@onready var rng := RandomNumberGenerator.new()

var bullet_color: Color = Color(1, 0.7, 0.7)

var aim_angle: float
var rotation_speed: float = 0.75

func _ready() -> void:
	e.reload_time_changed.connect(update_reload)
	rotation = PI/2 # to account for the sprite's initial rotation

func _process(_delta: float) -> void:
	# slowly rotates towards player, not instant rotation
	if (e.can_fire 
	and e.ammo == e.max_ammo
	and t_first_shot.is_stopped()):
		t_first_shot.start()


func _physics_process(delta: float) -> void:
	# to slowly pivot
	var target_direction: Vector2 = EnemyAiManager.player_position - global_position
	var angle_to: float = self.transform.x.angle_to(target_direction)
	aim_angle = rotation
	e.sprite_main.rotation = rotation - PI/2
	self.rotate(sign(angle_to) * min(delta * rotation_speed, abs(angle_to)))


func shoot(projectile: PackedScene, direction: Vector2) -> void:
	var pro_instance: Bullet = projectile.instantiate()
	if pro_instance:
		pro_instance.global_position = bullet_origin.global_position
		
		pro_instance.speed = 200.0
		pro_instance.direction = direction
		pro_instance.rotation = direction.angle()
		pro_instance.damage = 1.0
		pro_instance.set_collision_mask_value(3, true) # to look for player
		pro_instance.set_collision_layer_value(6, true) ## for parry
		pro_instance.modulate = bullet_color
		pro_instance.max_distance = e.vision_range + 250
		get_tree().root.add_child(pro_instance)
	elif pro_instance == null:
		print(projectile)


func burst_shoot() -> void:
	shoot(ProjectileScene, Vector2.RIGHT.rotated(aim_angle))
	e.ammo -= 1
	if t_reload.is_stopped():
		t_reload.start()


func update_reload(new_reload: float) -> void:
	t_reload.wait_time = new_reload


func _on_reload_timeout() -> void: # CHANGE RELOAD WAIT TIME IN THE ENEMY NODE (OWNER)
	e.ammo = e.max_ammo


func _on_before_first_shot_timeout() -> void:
	burst_shoot()
