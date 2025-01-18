extends Node2D
class_name Knight_UltimateComponent

signal charge_spent(used_charge: float)

@export var GrandBoltScene: PackedScene
@export var LightningBoltScene: PackedScene
@export var HomingMissileScene: PackedScene
@export var sfx_grand_ballista: AudioStream

## charge tier colors
var _red_weapon := Color(2, 1, 0.4)
var _yellow_weapon := Color(2, 2, 0.4)

## logic
var _aim_direction := Vector2.ZERO

## charge stuff
var _charge: float
var _charge_threshold: float
var _charge_tiers: int

## set by AM
var ult_bullet_properties := BulletProperties.new()
var enhanced_bullet_properties := BulletProperties.new()
var missile_bullet_properties := BulletProperties.new()

var missiles_enabled: bool

@onready var _character: Character = owner ## this is still weird but eh
@onready var _t_ult_cooldown: Timer = $ult_cooldown

## given by AM, required for input_ult, aim direction, mouse direction
@onready var PlayerInfo: PlayerInfoResource

## ideally, components dont know the ability manager
## but the AM does know the components

@onready var mobile_controls: bool = \
		ProjectSettings.get_setting("application/run/MobileControlsEnabled")

func _process(_delta: float) -> void:
	if not _character.enabled or _character.is_dead:
		return
	
	if _charge >= _charge_threshold:
		if _charge >= _charge_threshold:
			_character.wpn.modulate = _red_weapon
		else:
			_character.wpn.modulate = _yellow_weapon
		if not mobile_controls:
			if PlayerInfo.input_ult:
				_character.sprite_look_at(PlayerInfo.mouse_direction)
			if Input.is_action_just_released("right_click"):
				var tier := _spend_charge_to_tier()
				_activate_ult(tier)
		else:
			if PlayerInfo.input_ult and _t_ult_cooldown.is_stopped():
				_character.sprite_look_at(PlayerInfo.aim_direction)
				var tier := _spend_charge_to_tier()
				_mobile_activate_ult(tier)
	else:
		_character.wpn.modulate = Color(1, 1, 1)


func _physics_process(_delta: float) -> void:
	if not _character.enabled or _character.is_dead:
		return
	
	if PlayerInfo.input_ult:
		_character.wpn.position = Vector2(3, 16) + Vector2(
				randf_range(-0.6, 0.6), randf_range(-0.9, 0.9))
	else:
		_character.wpn.position = Vector2(3, 16)

func shoot(bullet: PackedScene, direction: Vector2, tier: int) -> void:
	assert(bullet, "missing ref")
	var ult_bullet: Bullet = bullet.instantiate()
	ult_bullet.global_position = self.global_position
	
	ult_bullet.ep 			= ult_bullet_properties.ep
	ult_bullet.max_distance 	= ult_bullet_properties.max_distance
	ult_bullet.speed 			= ult_bullet_properties.speed
	ult_bullet.damage 		= ult_bullet_properties.final_damage

	ult_bullet.direction 		= direction
	ult_bullet.rotation 		= direction.angle()
	ult_bullet.set_collision_mask_value(4, true)
	ult_bullet.scale = Vector2(1, 1)

	SoundPlayer.play_sound(sfx_grand_ballista, -4, 1.1)
	if tier == 2:
		ult_bullet.piercing = true
	get_tree().root.add_child(ult_bullet)


func _shoot_extra(bullet: PackedScene, direction: Vector2) -> void:
	assert(bullet, "missing ref")
	var enhanced_bullet: Bullet = bullet.instantiate()
	enhanced_bullet.global_position = self.global_position
	
	enhanced_bullet.ep 			= enhanced_bullet_properties.ep
	enhanced_bullet.max_distance 	= enhanced_bullet_properties.max_distance
	enhanced_bullet.speed 		= enhanced_bullet_properties.speed
	enhanced_bullet.damage 		= enhanced_bullet_properties.final_damage

	enhanced_bullet.direction 	= direction
	enhanced_bullet.rotation 	= direction.angle()
	enhanced_bullet.set_collision_mask_value(4, true)
	get_tree().root.add_child(enhanced_bullet)

func _shoot_missile(num_of_missiles: int) -> void:
	assert(HomingMissileScene, "missing export")
	var angle: float = 2*PI/num_of_missiles
	
	for i in range(num_of_missiles):
		var direction: Vector2 = Vector2(0, -1).rotated(angle * i)
		direction = direction.normalized()
		var missile: Bullet = HomingMissileScene.instantiate()
		missile.global_position = self.global_position
		
		missile.ep 		= missile_bullet_properties.ep
		missile.direction 	= direction
		missile.rotation 	= direction.angle()
		missile.set_collision_mask_value(4, true)
		missile.max_distance = missile_bullet_properties.max_distance
		missile.damage 	= missile_bullet_properties.final_damage
		missile.speed 		= missile_bullet_properties.speed
		#missile.rotation_speed = 10
		get_tree().root.add_child(missile)

func _activate_ult(tier: int) -> void:
	if _character.is_dead: ## make sure player still alive before firing
		return
	_character.apply_player_cam_shake(1)
	
	_aim_direction = PlayerInfo.mouse_direction if not mobile_controls else PlayerInfo.aim_direction

	if tier == 2:
		shoot(GrandBoltScene, _aim_direction, tier)
		var _angle: float
		_angle = -4 * PI/180
		_shoot_extra(LightningBoltScene, _aim_direction.rotated(_angle))
		_angle = 0
		_shoot_extra(LightningBoltScene, _aim_direction.rotated(_angle))
		_angle = 4 * PI/180
		_shoot_extra(LightningBoltScene, _aim_direction.rotated(_angle))
	else:
		shoot(GrandBoltScene, _aim_direction, tier)

	if missiles_enabled:
		_shoot_missile(3 * tier)

func _mobile_activate_ult(tier: int) -> void:	## for mobile controls, no need to aim ult
	_t_ult_cooldown.start()
	await _t_ult_cooldown.timeout

	_activate_ult(tier)
	PlayerInfo.ult_finished.emit(_aim_direction)

func _spend_charge_to_tier() -> int:
	var used_charge: float = 0
	var tier := 0
	for _i in _charge_tiers:
		if used_charge < _charge:
			used_charge += _charge_threshold
			tier += 1
		else:
			break
	_charge = 0 ## to ensure ult cant be immediately spammed until update_charge is called
	charge_spent.emit(used_charge)
	return tier

## public function called by AM
func update_charge(charge: float, charge_threshold: float, charge_tiers: int) -> void:
	_charge = charge
	_charge_threshold = charge_threshold
	_charge_tiers = charge_tiers