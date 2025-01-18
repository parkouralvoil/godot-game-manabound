extends Node2D
class_name Knight_AttackComponent

@export var BasicBoltScene: PackedScene 
@export var LightningBoltScene: PackedScene

var _burst_counter: int = 0

# set by AM
var basic_bullet_properties := BulletProperties.new()
var enhanced_bullet_properties := BulletProperties.new()

var enhanced_burst_shot_enabled: bool
var double_shot_enabled: bool

@onready var character: Character = owner
@onready var PlayerInfo: PlayerInfoResource ## given by AM

@onready var t_firerate: Timer = $firerate
@onready var t_recoil: Timer = $recoil

@onready var gunshot_player1: AudioStreamPlayer = $gunshotPlayer1
@onready var gunshot_player2: AudioStreamPlayer = $gunshotPlayer2

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	var can_shoot: bool = PlayerInfo.current_state != PlayerInfoResource.States.STANCE
	
	if !character.enabled or character.is_dead:
		return
	
	if !t_recoil.is_stopped():
		character.sprite_look_at(PlayerInfo.aim_direction)
		PlayerInfo.recoiling_from_basic_atk = true
	elif t_recoil.is_stopped() or !can_shoot:
		PlayerInfo.recoiling_from_basic_atk = false
	
	if PlayerInfo.input_attack and character.stats.ammo > 0 and can_shoot:
		if t_firerate.is_stopped():
			basic_atk()
			t_firerate.start()
			t_recoil.start()
			character.set_player_velocity(Vector2.ZERO)


func shoot(bullet: PackedScene, position_modifier: int) -> void:
	assert(bullet, "bruh its missing")
	var bullet_inst: Bullet = bullet.instantiate()
	var direction := PlayerInfo.aim_direction
	
	bullet_inst.global_position = (global_position + 
		direction.rotated(PI/2 * sign(position_modifier))
		* abs(position_modifier)
		)
	if bullet == BasicBoltScene:
		bullet_inst.ep 		= basic_bullet_properties.ep
		bullet_inst.speed 	= basic_bullet_properties.speed
		bullet_inst.max_distance = basic_bullet_properties.max_distance
		bullet_inst.damage 	= basic_bullet_properties.final_damage
	else:
		bullet_inst.ep 		= enhanced_bullet_properties.ep
		bullet_inst.speed 	= enhanced_bullet_properties.speed
		bullet_inst.max_distance = enhanced_bullet_properties.max_distance
		bullet_inst.damage 	= enhanced_bullet_properties.final_damage
	
	bullet_inst.direction = direction
	bullet_inst.rotation = direction.angle()
	bullet_inst.set_collision_mask_value(4, true)
	get_tree().root.add_child(bullet_inst)


func basic_atk() -> void:
	character.stats.ammo -= 1
	character.apply_player_cam_shake(1)
	var p_scene: PackedScene
	p_scene = BasicBoltScene if _burst_counter < 2 else LightningBoltScene
	
	if double_shot_enabled:
		gunshot_player1.pitch_scale = 0.8
		gunshot_player2.pitch_scale = 0.8
		shoot(p_scene, 4)
		shoot(p_scene, -4)
		gunshot_player1.play()
		gunshot_player2.play()
	else:
		shoot(p_scene, 0)
		gunshot_player1.pitch_scale = 0.9
		gunshot_player1.play()
	
	if enhanced_burst_shot_enabled:
		_burst_counter = (_burst_counter + 1) % 3
	else:
		_burst_counter = 0
	
	t_firerate.wait_time = 1 / character.stats.firerate
	if t_firerate.wait_time > 0.2: 
		# semi
		t_recoil.wait_time = 0.15
	else: 
		# auto
		t_recoil.wait_time = 0.2
