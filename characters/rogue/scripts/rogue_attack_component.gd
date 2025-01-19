extends Character_AttackComponent
class_name Rogue_AttackComponent

@export var FireBladeProjectile: PackedScene 
@export var RogueMeleeHitDown: PackedScene
@export var RogueMeleeHitUp: PackedScene

@export var sfx_hasAmmoMeleeSwing: AudioStream
@export var sfx_noAmmoMeleeSwing: AudioStream

var _melee_combo: int = 0
var can_fire_at_zero_ammo := false
var zero_ammo_damage_multiplier: float
var extra_energy_enabled := false

# TEMPORARY, needs to be reworked
var _element := CombatManager.Elements.FIRE

var fire_blade_bullet_properties := BulletProperties.new()
var melee_hit_explosion_properties := ExplosionProperties.new()

@onready var _melee_arm: Sprite2D = $melee_arm
@onready var _melee_wpn: Sprite2D = $melee_arm/melee_wpn

func _ready() -> void:
	_melee_arm.hide()

# region: Inherited functions
func _basic_atk() -> void:
	if not _t_firerate.is_stopped():
		return
	var sfx := sfx_hasAmmoMeleeSwing if character.stats.ammo > 0 else \
			sfx_noAmmoMeleeSwing
	
	SoundPlayer.play_sound(sfx, -10, 1.1)
	character.apply_player_cam_shake(1)

	_melee_arm.show()
	match _melee_combo:
		0: ## downwards swing
			_do_swing_animation(true)
			_melee_combo = 1
			_firerate_modifier = 1
		_: ## upwards swing
			_do_swing_animation(false)
			_melee_combo = 0
			_firerate_modifier = 1.6

func _check_if_can_shoot() -> bool: ## can be modified if needed
	return (PlayerInfo.current_state != PlayerInfoResource.States.STANCE 
			and not PlayerInput.want_to_choose_boost_direction
			and (character.stats.ammo > 0 or can_fire_at_zero_ammo)
	)
#endregion

func _process(_delta: float) -> void:
	if not character.enabled:
		_melee_arm.hide()
	
	super(_delta)
	print_debug(_check_if_can_shoot())
	if _t_firerate.is_stopped():
		_melee_arm.hide()

func _update_recoil_and_look_at() -> void:
	if _melee_arm.visible:
		character.sprite_look_at(PlayerInfo.aim_direction)
		PlayerInfo.recoiling_from_basic_atk = true
	else:
		PlayerInfo.recoiling_from_basic_atk = false

func _shoot(bullet_scene: PackedScene, bullet_properties: BulletProperties, dmg_multiplier: float, color: Color) -> void:
	assert(bullet_scene, "bruh its missing")
	var bullet: Bullet = bullet_scene.instantiate()
	var direction := PlayerInfo.aim_direction
	
	bullet_properties.final_damage *= dmg_multiplier
	_set_bullet_properties(bullet, bullet_properties)

	bullet.element 		= _element
	bullet.modulate 	= color
	bullet.global_position = self.global_position
	bullet.direction 	= direction
	bullet.rotation 	= direction.angle()
	get_tree().root.add_child(bullet)

func _spawn_melee_hit(melee_impact_scene: PackedScene, explosion_property: ExplosionProperties) -> void:
	assert(melee_impact_scene, "Missing packed scene at %s" % name)
	var dmg_instance: DamageImpact = melee_impact_scene.instantiate()
	var direction: Vector2 = PlayerInfo.aim_direction
	
	dmg_instance.ep 	= explosion_property.ep
	dmg_instance.damage = explosion_property.final_damage
	dmg_instance.scale 	= Vector2(1, 1) * explosion_property.size
	dmg_instance.element = _element

	dmg_instance.global_position 	= global_position
	dmg_instance.can_generate_extra_energy = extra_energy_enabled
	dmg_instance.rotation 			= direction.angle()
	dmg_instance.set_collision_mask_value(4, true)
	get_tree().root.add_child(dmg_instance)


func _try_fire_projectile() -> void:
	if character.stats.ammo > 0:
		character.stats.ammo -= 1
		await get_tree().physics_frame
		_shoot(FireBladeProjectile, fire_blade_bullet_properties, 
				1, Color(1, 1, 1))
	elif can_fire_at_zero_ammo:
		await get_tree().physics_frame
		_shoot(FireBladeProjectile, fire_blade_bullet_properties, 
				zero_ammo_damage_multiplier, Color(0.8, 0.8, 0.8))


func _do_swing_animation(downwards: bool) -> void:
	character.sprite_look_at(PlayerInfo.aim_direction)
	await get_tree().physics_frame
	var iniital_rot: float
	var aim_angle: float = PlayerInfo.aim_direction.angle()
	var duration: float = _t_firerate.wait_time/2
	var anim_slash_rot: float
	
	scale = character.anim_sprite.scale ## this is so budots
	## swing sword downwards
	if downwards:
		if PlayerInfo.aim_direction.x >= 0:
			iniital_rot = aim_angle - deg_to_rad(180)
			anim_slash_rot = aim_angle - deg_to_rad(20)
		else:
			iniital_rot = aim_angle + deg_to_rad(180)
			anim_slash_rot = aim_angle + deg_to_rad(20)
		var t: Tween = create_tween()
		t.tween_property(_melee_arm, "global_rotation", anim_slash_rot, duration).from(iniital_rot)
		t.parallel().tween_property(_melee_wpn, "rotation", deg_to_rad(135), duration).from(deg_to_rad(45))
		await t.finished
		var t2: Tween = create_tween()
		_spawn_melee_hit(RogueMeleeHitDown, melee_hit_explosion_properties)
		_try_fire_projectile()
		t2.tween_property(_melee_arm, "global_rotation", aim_angle, duration/2).from(anim_slash_rot)
	## swing sword upwards
	else:
		var final_rot: float
		if PlayerInfo.aim_direction.x >= 0:
			iniital_rot = aim_angle + deg_to_rad(20)
			final_rot = aim_angle - deg_to_rad(180)
			anim_slash_rot = aim_angle - deg_to_rad(160)
		else:
			iniital_rot = aim_angle - deg_to_rad(20)
			final_rot = aim_angle + deg_to_rad(180)
			anim_slash_rot = aim_angle + deg_to_rad(160)
		var t: Tween = create_tween()
		t.tween_property(_melee_arm, "global_rotation", anim_slash_rot, duration).from(iniital_rot)
		t.parallel().tween_property(_melee_wpn, "rotation", deg_to_rad(135), duration).from(deg_to_rad(165))
		await t.finished
		var t2: Tween = create_tween()
		_spawn_melee_hit(RogueMeleeHitUp, melee_hit_explosion_properties)
		_try_fire_projectile()
		t2.tween_property(_melee_arm, "global_rotation", final_rot, duration/2).from(anim_slash_rot)
