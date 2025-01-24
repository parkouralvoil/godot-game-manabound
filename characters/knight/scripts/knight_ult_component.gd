extends Character_UltComponent
class_name Knight_UltComponent

@export var GrandBoltScene: PackedScene
@export var LightningBoltScene: PackedScene
@export var HomingMissileScene: PackedScene
@export var sfx_grand_ballista: AudioStream

## charge tier colors
var _red_weapon := Color(2, 1, 0.4)
var _yellow_weapon := Color(2, 2, 0.4)

## set by AM
var ult_bullet_properties := BulletProperties.new()
var enhanced_bullet_properties := BulletProperties.new()
var missile_bullet_properties := BulletProperties.new()

var missiles_enabled: bool

# region: inherited functions of Character_UltComponent
func _change_weapon_color_based_on_charge(old_charge: float, threshold: float) -> void:
	if old_charge >= threshold * 2:
		_character.wpn.modulate = _red_weapon
	elif old_charge >= threshold * 1:
		_character.wpn.modulate = _yellow_weapon
	else:
		_character.wpn.modulate = _default_weapon_color

func _activate_ult(tier: int) -> void:
	super(tier) ## very important

	_shoot_main(GrandBoltScene, ult_bullet_properties, _aim_direction, tier)
	if tier == 2:
		_shoot_extra(LightningBoltScene, enhanced_bullet_properties, _aim_direction.rotated(-4 * PI/180))
		_shoot_extra(LightningBoltScene, enhanced_bullet_properties, _aim_direction.rotated(0))
		_shoot_extra(LightningBoltScene, enhanced_bullet_properties, _aim_direction.rotated(4 * PI/180))

	if missiles_enabled:
		_shoot_missile_barrage(3 * tier)
#endregion

func _shoot_main(bullet_scene: PackedScene, bullet_properties: BulletProperties, direction: Vector2, tier: int) -> void:
	assert(bullet_scene, "missing ref")
	var ult_bullet: Bullet = bullet_scene.instantiate()
	
	_set_bullet_properties(ult_bullet, bullet_properties)

	ult_bullet.global_position 	= self.global_position
	ult_bullet.direction 		= direction
	ult_bullet.rotation 		= direction.angle()
	ult_bullet.scale = Vector2(1, 1)

	SoundPlayer.play_sound(sfx_grand_ballista, -4, 1.1)
	if tier == 2 and ult_bullet is GrandBoltBullet: ## how dafuq do i fix this
		ult_bullet.piercing = true
	get_tree().root.add_child(ult_bullet)


func _shoot_extra(bullet_scene: PackedScene, bullet_properties: BulletProperties, direction: Vector2) -> void:
	assert(bullet_scene, "missing ref")
	var enhanced_bullet: Bullet = bullet_scene.instantiate()
	enhanced_bullet.global_position = self.global_position
	
	_set_bullet_properties(enhanced_bullet, bullet_properties)

	enhanced_bullet.direction 	= direction
	enhanced_bullet.rotation 	= direction.angle()
	get_tree().root.add_child(enhanced_bullet)


func _shoot_missile(bullet_scene: PackedScene, bullet_properties: BulletProperties, direction: Vector2) -> void:
	assert(bullet_scene, "missing ref")
	var missile: Bullet = bullet_scene.instantiate()
	
	_set_bullet_properties(missile, bullet_properties)

	missile.global_position = self.global_position
	missile.direction 	= direction
	missile.rotation 	= direction.angle()
	#missile.rotation_speed = 10
	get_tree().root.add_child(missile)


func _shoot_missile_barrage(num_of_missiles: int) -> void:
	var angle: float = 2*PI/num_of_missiles

	for i in range(num_of_missiles):
		var direction: Vector2 = Vector2(0, -1).rotated(angle * i)
		direction = direction.normalized()
		_shoot_missile(HomingMissileScene, missile_bullet_properties, direction)
