extends Node2D
class_name Rogue_AttackComponent

@export var FireBladeProjectile: PackedScene 
@export var RogueMeleeHitDown: PackedScene
@export var RogueMeleeHitUp: PackedScene

@onready var character: Character = owner
@onready var PlayerInfo: PlayerInfoResource ## given by AM
@onready var AM: Rogue_AbilityManager = get_parent()

@onready var t_firerate: Timer = $firerate
@onready var melee_arm: Sprite2D = $melee_arm
@onready var melee_wpn: Sprite2D = $melee_arm/melee_wpn

var melee_combo: int = 0
var max_melee_combo: int = 1

var meleeing: bool = false
var default_firerate_time: float

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

func shoot(bullet: PackedScene, dmg: float, color: Color) -> void:
	assert(bullet, "bruh its missing")
	var bul_instance: Bullet = bullet.instantiate()
	var direction := PlayerInfo.aim_direction
	
	bul_instance.global_position = (global_position)
	
	bul_instance.speed = AM.bullet_speed
	bul_instance.damage = dmg
	bul_instance.max_distance = AM.ranged_max_distance
	bul_instance.element = CombatManager.Elements.FIRE
	bul_instance.modulate = color
	
	bul_instance.ep = character.stats.EP
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
	
	dmg_instance.ep = character.stats.EP
	dmg_instance.damage = AM.melee_dmg
	dmg_instance.element = CombatManager.Elements.FIRE
	dmg_instance.can_generate_extra_energy = AM.melee_extra_energy_enabled
	dmg_instance.rotation = direction.angle()
	dmg_instance.set_collision_mask_value(4, true)
	dmg_instance.scale = Vector2(1, 1) * AM.melee_size
	get_tree().root.add_child(dmg_instance)


func basic_atk() -> void: ## swing sword
	default_firerate_time = (1/character.stats.firerate)
	character.apply_player_cam_shake(1)
	
	## BIG ISSUE:
		## IF melee attacks can shoot projectiles (terraria melee)
		## then we DONT need the ReversEstory melee assist (step forward to go closer)
		## most of the time youll hit the enemy with projectiles
		## if you want to go melee,
			## ill just make the melee range much bigger for alot of leeway
	match melee_combo:
		0: ## downwards swing
			do_swing_animation(true)
			melee_combo = 1
			t_firerate.wait_time = default_firerate_time
		_: ## upwards swing
			do_swing_animation(false)
			melee_combo = 0
			t_firerate.wait_time = default_firerate_time * 1.4


func fire_projectile() -> void:
	if character.stats.ammo > 0:
		character.stats.ammo -= 1
		await get_tree().physics_frame
		shoot(FireBladeProjectile, AM.ranged_dmg, Color(1, 1, 1))
	elif AM.zero_ammo_atk_enabled:
		await get_tree().physics_frame
		shoot(FireBladeProjectile, AM.zero_ammo_ranged_dmg, Color(0.8, 0.8, 0.8))


func do_swing_animation(downwards: bool) -> void:
	character.sprite_look_at(PlayerInfo.aim_direction)
	await get_tree().physics_frame
	var iniital_rot: float
	var aim_angle: float = PlayerInfo.aim_direction.angle()
	var duration: float
	var anim_slash_rot: float
	
	get_parent().scale = character.anim_sprite.scale ## this is so budots
	## swing sword downwards
	if downwards:
		if PlayerInfo.aim_direction.x > 0:
			iniital_rot = aim_angle - deg_to_rad(180)
			anim_slash_rot = aim_angle - deg_to_rad(20)
		else:
			iniital_rot = aim_angle + deg_to_rad(180)
			anim_slash_rot = aim_angle + deg_to_rad(20)
		var t: Tween = create_tween()
		t.set_ease(Tween.EASE_OUT)
		duration = t_firerate.wait_time/2
		t.tween_property(melee_arm, "global_rotation", anim_slash_rot, duration).from(iniital_rot)
		t.parallel().tween_property(melee_wpn, "rotation", deg_to_rad(135), duration).from(deg_to_rad(45))
		await t.finished
		var t2: Tween = create_tween()
		t2.set_ease(Tween.EASE_OUT)
		melee_hit(RogueMeleeHitDown)
		fire_projectile()
		t2.tween_property(melee_arm, "global_rotation", aim_angle, duration).from(anim_slash_rot)
	## swing sword upwards
	else:
		var final_rot: float
		if PlayerInfo.aim_direction.x > 0:
			iniital_rot = aim_angle + deg_to_rad(20)
			final_rot = aim_angle - deg_to_rad(180)
			anim_slash_rot = aim_angle - deg_to_rad(160)
		else:
			iniital_rot = aim_angle - deg_to_rad(20)
			final_rot = aim_angle + deg_to_rad(180)
			anim_slash_rot = aim_angle + deg_to_rad(160)
		var t: Tween = create_tween()
		t.set_ease(Tween.EASE_OUT)
		duration = t_firerate.wait_time/2
		t.tween_property(melee_arm, "global_rotation", anim_slash_rot, duration).from(iniital_rot)
		t.parallel().tween_property(melee_wpn, "rotation", deg_to_rad(135), duration).from(deg_to_rad(165))
		await t.finished
		var t2: Tween = create_tween()
		t2.set_ease(Tween.EASE_OUT)
		melee_hit(RogueMeleeHitUp)
		fire_projectile()
		t2.tween_property(melee_arm, "global_rotation", final_rot, duration).from(anim_slash_rot)
