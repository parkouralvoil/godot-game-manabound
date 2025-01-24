extends Node2D
class_name Character_UltComponent

signal charge_spent(used_charge: float)

var _default_weapon_color := Color(1, 1, 1)

## logic
var _aim_direction := Vector2.ZERO

## charge stuff
var _charge: float = 0
var _charge_threshold: float = 50
var _charge_tiers: int

@onready var _character: Character = owner ## this is still weird but eh
@onready var _t_ult_cooldown: Timer = $ult_cooldown

## given by AM, required for input_ult, aim direction, mouse direction
@onready var PlayerInfo: PlayerInfoResource
@onready var mobile_controls: bool = \
		ProjectSettings.get_setting("application/run/MobileControlsEnabled")

func _process(_delta: float) -> void:
	if not _character.enabled or _character.is_dead:
		return

	if _charge >= _charge_threshold:
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

func _change_weapon_color_based_on_charge(old_charge: float, threshold: float) -> void:
	pass

func _set_bullet_properties(bullet: Bullet, properties: BulletProperties) -> void:
	## changes Bullet attributes
	bullet.ep 			= properties.ep
	bullet.max_distance = properties.max_distance
	bullet.speed 		= properties.speed
	bullet.damage 		= properties.final_damage
	bullet.set_collision_mask_value(4, true)	## to make it target enemies

func _activate_ult(tier: int) -> void:
	## modify this function to actually use the ult
	if _character.is_dead: ## make sure player still alive before firing
		return
	_character.apply_player_cam_shake(1)
	
	_aim_direction = PlayerInfo.mouse_direction if not mobile_controls else PlayerInfo.aim_direction
	pass ##

func _mobile_activate_ult(tier: int) -> void:	## for mobile controls, no need to aim ult
	_t_ult_cooldown.start()
	await _t_ult_cooldown.timeout

	_activate_ult(tier)
	PlayerInfo.ult_finished.emit(_aim_direction)

func _spend_charge_to_tier() -> int:
	var used_charge: float = 0
	var tier := 0
	for _i in _charge_tiers:
		if used_charge + _charge_threshold <= _charge:
			used_charge += _charge_threshold
			tier += 1
		else:
			break
	_charge = 0 ## to ensure ult cant be immediately spammed until update_charge is called
	charge_spent.emit(used_charge)
	return tier

## public function called by AM
func update_charge(charge: float, charge_threshold: float, charge_tiers: int) -> void:
	_change_weapon_color_based_on_charge(charge, charge_threshold)
	_charge = charge
	_charge_threshold = charge_threshold
	_charge_tiers = charge_tiers