extends Character_AttackComponent
class_name Knight_AttackComponent

@export var BasicBoltScene: PackedScene 
@export var LightningBoltScene: PackedScene

var _burst_counter: int = 0

# set by AM
var basic_bullet_properties := BulletProperties.new()
var enhanced_bullet_properties := BulletProperties.new()

var enhanced_burst_shot_enabled: bool
var double_shot_enabled: bool

@onready var _gunshot_player1: AudioStreamPlayer = $gunshotPlayer1
@onready var _gunshot_player2: AudioStreamPlayer = $gunshotPlayer2

# region: inherited functions
func _basic_atk() -> void:
	character.stats.ammo -= 1
	character.apply_player_cam_shake(1)
	var p_scene: PackedScene
	var property: BulletProperties
	if _burst_counter < 2:
		p_scene = BasicBoltScene
		property = basic_bullet_properties
	else:
		p_scene = LightningBoltScene
		property = enhanced_bullet_properties
	
	if double_shot_enabled:
		_gunshot_player1.pitch_scale = 0.8
		_gunshot_player2.pitch_scale = 0.8
		_shoot_main(p_scene, property, 4)
		_shoot_main(p_scene, property, -4)
		_gunshot_player1.play()
		_gunshot_player2.play()
	else:
		_shoot_main(p_scene, property, 0)
		_gunshot_player1.pitch_scale = 0.9
		_gunshot_player1.play()
	
	if enhanced_burst_shot_enabled:
		_burst_counter = (_burst_counter + 1) % 3
	else:
		_burst_counter = 0
# endregion

func _shoot_main(bullet_scene: PackedScene, bullet_properties: BulletProperties, position_modifier: int) -> void:
	assert(bullet_scene, "bruh its missing")
	var bullet: Bullet = bullet_scene.instantiate()
	var direction := PlayerInfo.aim_direction

	_set_bullet_properties(bullet, bullet_properties)
	
	bullet.global_position = (global_position + 
		direction.rotated(PI/2 * sign(position_modifier))
		* abs(position_modifier)
		)
	bullet.direction = direction
	bullet.rotation = direction.angle()
	get_tree().root.add_child(bullet)