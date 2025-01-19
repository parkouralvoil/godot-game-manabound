extends Character_UltComponent
class_name Witch_UltComponent

@export var FrostNovaScene: PackedScene
@export var sfx_FrostNova: AudioStream

var _blue_color := Color(0.5, 2, 2)

var ult_explosion_properties := ExplosionProperties.new()
var can_crystalize: bool = false
var explosion_count: int = 0

# region: inherited functions of Character_UltComponent
func _change_weapon_color_based_on_charge() -> void:
	if _charge >= _charge_threshold * 1:
		_character.wpn.modulate = _blue_color
	else:
		_character.wpn.modulate = _default_weapon_color

func _activate_ult(tier: int) -> void:
	super(tier) ## very important
	spawn_area_effect(FrostNovaScene, PlayerInfo.target_position)	

func _mobile_activate_ult(tier: int) -> void:	## for mobile controls, no need to aim ult
	_t_ult_cooldown.start()
	await _t_ult_cooldown.timeout

	_activate_ult(tier)
	PlayerInfo.ult_finished.emit(Vector2.ZERO)
# endregion
	

func spawn_area_effect(area_effect: PackedScene, target_pos: Vector2) -> void:
	assert(area_effect, "missing proj")
	var effect_instance: FrostStorm = area_effect.instantiate()

	effect_instance.ep 		= ult_explosion_properties.ep
	effect_instance.size	= ult_explosion_properties.size
	effect_instance.damage 	= ult_explosion_properties.final_damage

	effect_instance.global_position = target_pos
	effect_instance.max_spawn_counter = explosion_count

	if can_crystalize:
		effect_instance.debuff = CombatManager.Debuffs.CRYSTALIZED
	
	SoundPlayer.play_sound_2D(target_pos, sfx_FrostNova, -10)
	get_tree().root.add_child(effect_instance)
