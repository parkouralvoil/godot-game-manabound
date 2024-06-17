extends Node2D
class_name Rogue_AttackComponent

@export var FireBladeProjectile: PackedScene 
@export var RogueMeleeHitDown: PackedScene
@export var RogueMeleeHitUp: PackedScene

@onready var character: Character = owner
@onready var AM: Rogue_AbilityManager = get_parent()

@onready var t_firerate: Timer = $firerate
@onready var melee_arm: Sprite2D = $melee_arm
@onready var melee_wpn: Sprite2D = $melee_arm/melee_wpn

var melee_combo: int = 0
var max_melee_combo: int = 1

var meleeing: bool = false

func _ready() -> void:
	melee_arm.hide()

func _process(_delta: float) -> void:
	var can_shoot: bool = PlayerInfo.current_state == PlayerInfo.States.IDLE
	
	if not character.enabled:
		melee_arm.hide()
		PlayerInfo.melee_aim_lock = false
		return
	
	if melee_arm.visible:
		PlayerInfo.basic_attacking = true
		PlayerInfo.melee_aim_lock = true
	else:
		PlayerInfo.melee_aim_lock = false
		PlayerInfo.basic_attacking = false
	
	if PlayerInfo.input_attack and can_shoot:
		melee_arm.show()
		if t_firerate.is_stopped():
			character.set_player_velocity(Vector2.ZERO)
			basic_atk()
			t_firerate.start()
		
	elif t_firerate.is_stopped() or not can_shoot:
		melee_arm.hide()

func shoot(bullet: PackedScene, position_modifier: int) -> void:
	assert(bullet, "bruh its missing")
	var bul_instance: Bullet = bullet.instantiate()
	var direction := PlayerInfo.aim_direction
	
	bul_instance.global_position = (global_position + 
		direction.rotated(PI/2 * sign(position_modifier))
		* abs(position_modifier)
		)
	
	bul_instance.speed = AM.bullet_speed
	bul_instance.damage = AM.damage_basic_bol
	bul_instance.max_distance = AM.max_distance
	
	bul_instance.direction = direction
	bul_instance.rotation = direction.angle()
	bul_instance.set_collision_mask_value(4, true)
	get_tree().root.add_child(bul_instance)

func melee_hit(melee: PackedScene) -> void:
	assert(melee, "bruh its missing")
	var dmg_instance: DamageImpact = melee.instantiate()
	var direction: Vector2 = PlayerInfo.aim_direction
	
	#var position_offset: Vector2 = melee_range * Vector2.RIGHT.rotated(direction.angle())
	
	dmg_instance.global_position = global_position #+ position_offset
	
	dmg_instance.damage = 10
	#print("spawned")
	dmg_instance.rotation = direction.angle()
	dmg_instance.set_collision_mask_value(4, true)
	get_tree().root.add_child(dmg_instance)


func basic_atk() -> void: ## swing sword
	#character.ammo -= 1
	character.apply_player_cam_shake(1)
	var p_scene: PackedScene # projectile
	
	## BIG ISSUE:
		## IF melee attacks can shoot projectiles (terraria melee)
		## then we DONT need the ReversEstory melee assist (step forward to go closer)
		## most of the time youll hit the enemy with projectiles
		## if you want to go melee,
			## ill just make the melee range much bigger for alot of leeway
	match melee_combo:
		0: ## downwards swing
			melee_hit(RogueMeleeHitDown)
			do_swing_animation(true)
			melee_combo = 1
			t_firerate.wait_time = 0.22
		_: ## upwards swing
			melee_hit(RogueMeleeHitUp)
			do_swing_animation(false)
			melee_combo = 0
			t_firerate.wait_time = 0.35


func do_swing_animation(downwards: bool) -> void:
	character.sprite_look_at(PlayerInfo.aim_direction)
	await get_tree().physics_frame
	var iniital_rot: float
	melee_arm.transform = character.arm_sprite.transform
	var aim_angle: float = PlayerInfo.aim_direction.angle()
	var duration: float
	## swing sword downwards
	if downwards:
		if PlayerInfo.aim_direction.x > 0:
			iniital_rot = aim_angle - deg_to_rad(180)
		else:
			iniital_rot = aim_angle + deg_to_rad(180)
		var t: Tween = create_tween()
		duration = clampf(0.18, 0.1, t_firerate.wait_time)
		t.tween_property(melee_arm, "global_rotation", aim_angle, duration).from(iniital_rot)
		t.parallel().tween_property(melee_wpn, "rotation", deg_to_rad(135), duration).from(deg_to_rad(45))
	
	## swing sword upwards
	else:
		var final_rot: float
		if PlayerInfo.aim_direction.x > 0:
			iniital_rot = aim_angle + deg_to_rad(20)
			final_rot = aim_angle - deg_to_rad(200)
		else:
			iniital_rot = aim_angle - deg_to_rad(20)
			final_rot = aim_angle + deg_to_rad(200)
		var t: Tween = create_tween()
		duration = clampf(0.23, 0.1, t_firerate.wait_time)
		t.tween_property(melee_arm, "global_rotation", final_rot, duration).from(iniital_rot)
		t.parallel().tween_property(melee_wpn, "rotation", deg_to_rad(135), duration).from(deg_to_rad(165))
