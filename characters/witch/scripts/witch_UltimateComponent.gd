extends Node2D
class_name Witch_UltimateComponent

@export var FrostNovaScene: PackedScene
@export var sfx_FrostNova: AudioStream
# this should have 2 charges
# by default, it only has 1 charge, strong single target bullet (like ac6 linear rifle), no piercing
# with upgrades:
# 2nd charge: piercing bullet, disappears on wall collision
# we can just have the explosion impact be "shockwave dealing minor dmg and additional lightning elem proc"

@onready var character: Character = owner
@onready var AM: Witch_AbilityManager = get_parent()

func _process(delta: float) -> void:
	raise_charge(delta)
	
	if !character.enabled:
		return
	
	PlayerInfo.current_charge_type = PlayerInfo.ChargeTypes.PASSIVE
	
	if character.charge >= character.max_charge:
		if PlayerInfo.input_ult:
			character.sprite_look_at(PlayerInfo.mouse_direction)
			character.wpn_sprite.modulate = Color(0.5, 2, 2)
		elif Input.is_action_just_released("right_click"): # this the best way
			spend_charge()
			character.wpn_sprite.modulate = Color(1, 1, 1)

func spawn_area_effect(area_effect: PackedScene, target_pos: Vector2) -> void:
	assert(area_effect, "missing proj")
	SoundPlayer.play_sound_2D(target_pos, sfx_FrostNova, -10)
	
	var effect_instance: FrostStorm = area_effect.instantiate()
	effect_instance.global_position = target_pos
	effect_instance.size = AM.explosion_scale
	effect_instance.damage = AM.frost_storm_dmg
	effect_instance.max_spawn_counter = AM.explosion_num
	if AM.skill_ult_crystalize:
		effect_instance.debuff = CombatManager.Debuffs.CRYSTALIZED
	
	get_tree().root.add_child(effect_instance)

func raise_charge(delta: float) -> void:
	character.charge = min(character.max_charge, character.charge + character.charge_rate * delta)

func spend_charge() -> void:
	spawn_area_effect(FrostNovaScene, get_global_mouse_position())
	character.charge = 0
