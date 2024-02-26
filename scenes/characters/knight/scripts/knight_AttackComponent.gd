extends Node2D

@export var BasicBoltScene: PackedScene 
@export var LightningBoltScene: PackedScene
var burst_counter: int = 0

@onready var AM: AbilityManager = get_parent()

@onready var t_firerate: Timer = $firerate
@onready var t_recoil: Timer = $recoil

#for bullets
var bullet_speed: float = 400
var damage_basic_bolt: float = 5
var damage_lightning_bolt: float = 10
var max_distance: float = 300

var can_shoot: bool = true

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	can_shoot = PlayerInfo.current_state != PlayerInfo.States.STANCE
	
	if !AM.enabled:
		return
	
	if !t_recoil.is_stopped():
		AM.sprite_look_at(PlayerInfo.aim_direction)
		PlayerInfo.basic_attacking = true
	elif t_recoil.is_stopped() or !can_shoot:
		PlayerInfo.basic_attacking = false
	
	if Input.is_action_pressed("left_click") and AM.ammo > 0 and can_shoot:
		if t_firerate.is_stopped():
			burst_shoot()
			t_firerate.start()
			t_recoil.start()
			AM.set_player_velocity(Vector2.ZERO)

func shoot(bullet: PackedScene) -> void:
	assert(bullet, "bruh its missing")
	var bul_instance: Bullet = bullet.instantiate()
	var direction := PlayerInfo.aim_direction
	AM.apply_player_cam_shake(1)
	AM.ammo -= 1
	
	bul_instance.global_position = self.global_position
	
	bul_instance.speed = bullet_speed
	bul_instance.damage = damage_basic_bolt if bullet == BasicBoltScene else damage_lightning_bolt
	bul_instance.max_distance = max_distance
	bul_instance.direction = direction
	bul_instance.rotation = direction.angle()
	bul_instance.set_collision_mask_value(4, true)
	get_tree().root.add_child(bul_instance)

func burst_shoot() -> void:
	shoot(BasicBoltScene)
	t_firerate.wait_time = 0.15
	t_recoil.wait_time = t_firerate.wait_time + 0.05
	#if burst_counter == 2:
		#shoot(LightningBoltScene)
		#t_firerate.wait_time = 0.15 # 0.3
		#t_recoil.wait_time = t_firerate.wait_time + 0.05
	#else:
		#shoot(BasicBoltScene)
		#t_firerate.wait_time = 0.15
		#t_recoil.wait_time = t_firerate.wait_time + 0.05
	burst_counter = (burst_counter + 1) % 3
