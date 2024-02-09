extends Node2D

var ProjectileScene: PackedScene = load("res://scenes/projectiles/bullet.tscn")
var LightningProjectileScene: PackedScene = load("res://scenes/projectiles/lightning_projectiles/lightning_bullet.tscn")
var burst_counter: int = 0

var AM: AbilityManager = null

@onready var t_firerate: Timer = $firerate

var bullet_speed: float = 400
var can_shoot: bool = true

func _ready():
	AM = get_parent()

func _process(delta):
	can_shoot = PlayerInfo.current_state != PlayerInfo.States.STANCE
	
	if !AM.enabled:
		return
	
	if Input.is_action_pressed("left_click") and AM.ammo > 0 and can_shoot:
		PlayerInfo.basic_attacking = true
		AM.sprite_look_at(PlayerInfo.aim_direction)
		if t_firerate.is_stopped():
			burst_shoot()
			t_firerate.start()
			AM.set_player_velocity(Vector2.ZERO)
		
	elif !Input.is_action_pressed("left_click") or t_firerate.is_stopped() or !can_shoot:
		PlayerInfo.basic_attacking = false
		burst_counter = 0

func shoot(projectile: PackedScene):
	var pro_instance := projectile.instantiate()
	var direction = PlayerInfo.aim_direction
	AM.apply_player_cam_shake(1)
	AM.ammo -= 1
	if pro_instance:
		pro_instance.global_position = self.global_position
		
		pro_instance.speed = bullet_speed
		pro_instance.direction = direction
		pro_instance.rotation = direction.angle()
		pro_instance.set_collision_mask_value(4, true)
		get_tree().root.add_child(pro_instance)
		print(pro_instance)
	elif pro_instance == null:
		print(projectile)

func burst_shoot():
	if burst_counter == 2:
		shoot(LightningProjectileScene)
		t_firerate.wait_time = 0.3
	else:
		shoot(ProjectileScene)
		t_firerate.wait_time = 0.15
	burst_counter = (burst_counter + 1) % 3
