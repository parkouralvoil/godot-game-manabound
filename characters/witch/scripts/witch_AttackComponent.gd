extends Node2D
class_name Witch_AttackComponent

@export var IceSpikeScene: PackedScene
@export var sfx_IceCast: AudioStream

@onready var character: Character = owner
@onready var PlayerInfo: PlayerInfoResource
@onready var AM: Witch_AbilityManager = get_parent()

@onready var t_firerate: Timer = $firerate
@onready var t_recoil: Timer = $recoil

#for bullets
var element: CombatManager.Elements = CombatManager.Elements.ICE

var can_shoot: bool = true

func _process(_delta: float) -> void:
	can_shoot = PlayerInfo.current_state != PlayerInfoResource.States.STANCE
	
	if !character.enabled:
		return
	
	if !t_recoil.is_stopped(): 
		character.sprite_look_at(PlayerInfo.aim_direction)
		PlayerInfo.recoiling_from_basic_atk = true
	elif t_recoil.is_stopped() or !can_shoot:
		PlayerInfo.recoiling_from_basic_atk = false
	
	if PlayerInfo.input_attack and character.stats.ammo > 0 and can_shoot and not character.is_dead:
		if t_firerate.is_stopped():
			basic_atk()
			t_firerate.start()
			t_recoil.start()
			character.set_player_velocity(Vector2.ZERO)

func shoot(bullet: PackedScene) -> void:
	assert(bullet, "bruh its missing")
	
	SoundPlayer.play_sound(sfx_IceCast, -10, 1.05)
	
	var bul_instance: IceSpikeBullet = bullet.instantiate()
	var direction: Vector2 = PlayerInfo.aim_direction
	
	bul_instance.ep = character.stats.ep
	bul_instance.global_position = global_position
	bul_instance.speed = AM.bullet_speed
	bul_instance.damage = AM.frost_spike_dmg
	bul_instance.max_distance = AM.max_distance
	bul_instance.direction = direction
	bul_instance.element = element
	bul_instance.rotation = direction.angle()
	
	if AM.level_basicAtk_second_icicle > 0:
		bul_instance.first_icicle = true
	else:
		bul_instance.first_icicle = false
		
	bul_instance.first_icicle_dmg = AM.first_icicle_dmg
	bul_instance.second_icicle_dmg = AM.second_icicle_dmg
	if AM.skill_basicAtk_crystalize:
		bul_instance.debuff = CombatManager.Debuffs.CRYSTALIZED
	bul_instance.set_collision_mask_value(4, true)
	get_tree().root.add_child(bul_instance)

func basic_atk() -> void:
	shoot(IceSpikeScene)
	character.apply_player_cam_shake(1)
	character.stats.ammo -= 1
	
	t_firerate.wait_time = 1 / character.stats.firerate
	if t_firerate.wait_time > 0.2: # semi
		t_recoil.wait_time = 0.15
	else: # auto
		t_recoil.wait_time = 0.2
