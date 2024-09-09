extends Node2D
class_name Knight_AttackComponent

@export var BasicBoltScene: PackedScene 
@export var LightningBoltScene: PackedScene
var burst_counter: int = 0

@onready var character: Character = owner
@onready var PlayerInfo: PlayerInfoResource ## given by AM
@onready var AM: Knight_AbilityManager = get_parent()

@onready var t_firerate: Timer = $firerate
@onready var t_recoil: Timer = $recoil

@export var sfx_gunshot: AudioStream

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	var can_shoot: bool = PlayerInfo.current_state != PlayerInfoResource.States.STANCE
	
	if !character.enabled or character.is_dead:
		return
	
	if !t_recoil.is_stopped():
		character.sprite_look_at(PlayerInfo.aim_direction)
		PlayerInfo.basic_attacking = true
	elif t_recoil.is_stopped() or !can_shoot:
		PlayerInfo.basic_attacking = false
	
	if PlayerInfo.input_attack and character.stats.ammo > 0 and can_shoot:
		if t_firerate.is_stopped():
			basic_atk()
			t_firerate.start()
			t_recoil.start()
			character.set_player_velocity(Vector2.ZERO)

func shoot(bullet: PackedScene, position_modifier: int) -> void:
	assert(bullet, "bruh its missing")
	var bul_instance: Bullet = bullet.instantiate()
	var direction := PlayerInfo.aim_direction
	
	bul_instance.global_position = (global_position + 
		direction.rotated(PI/2 * sign(position_modifier))
		* abs(position_modifier)
		)
	bul_instance.ep = character.stats.EP
	bul_instance.speed = AM.bullet_speed
	bul_instance.damage = (AM.damage_basic_bolt if bullet == BasicBoltScene 
		else AM.damage_lightning_bolt)
	bul_instance.max_distance = AM.max_distance
	
	bul_instance.direction = direction
	bul_instance.rotation = direction.angle()
	bul_instance.set_collision_mask_value(4, true)
	get_tree().root.add_child(bul_instance)


func basic_atk() -> void:
	character.stats.ammo -= 1
	character.apply_player_cam_shake(1)
	var p_scene: PackedScene
	p_scene = BasicBoltScene if burst_counter < 2 else LightningBoltScene
	
	if AM.skill_basicAtk_double:
		shoot(p_scene, 4)
		shoot(p_scene, -4)
		SoundPlayer.play_sound(sfx_gunshot, -15, 0.8)
		SoundPlayer.play_sound(sfx_gunshot, -15, 0.8)
	else:
		shoot(p_scene, 0)
		SoundPlayer.play_sound(sfx_gunshot, -15, 0.9)
	
	if AM.level_basicAtk_burst > 0:
		burst_counter = (burst_counter + 1) % 3
	else:
		burst_counter = 0
	
	t_firerate.wait_time = 1 / character.stats.firerate
	if t_firerate.wait_time > 0.2: # semi
		t_recoil.wait_time = 0.15
	else: # auto
		t_recoil.wait_time = 0.2
