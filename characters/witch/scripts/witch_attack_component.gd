extends Character_AttackComponent
class_name Witch_AttackComponent

@export var IceSpikeScene: PackedScene
@export var sfx_IceCast: AudioStream

## set by AM
var ice_spike_bullet_properties := BulletProperties.new()
var icicle_dmg_scaling: float
var second_icicle_enabled := false
var can_crystalize := false

# TEMPORARY, needs to be reworked
var _element: CombatManager.Elements = CombatManager.Elements.ICE

# region: Inherited functions
func _basic_atk() -> void:
	character.stats.ammo -= 1
	character.apply_player_cam_shake(1)
	_shoot_main(IceSpikeScene, ice_spike_bullet_properties)
#endregion


func _shoot_main(bullet_scene: PackedScene, bullet_properties: BulletProperties) -> void:
	assert(bullet_scene, "bruh its missing")
	
	var bullet: IceSpikeBullet = bullet_scene.instantiate()
	var direction: Vector2 = PlayerInfo.aim_direction
	var icicle_dmg := bullet_properties.final_damage * icicle_dmg_scaling
	
	_set_bullet_properties(bullet, bullet_properties)

	bullet.global_position = global_position
	bullet.direction 	= direction
	bullet.rotation 	= direction.angle()
	bullet.element 		= _element ## TODO: this should be set under properties
	
	bullet.first_icicle = true if second_icicle_enabled else false
	bullet.first_icicle_dmg = icicle_dmg

	if can_crystalize:
		bullet.debuff = CombatManager.Debuffs.CRYSTALIZED
	SoundPlayer.play_sound(sfx_IceCast, -10, 1.05)
	get_tree().root.add_child(bullet)
