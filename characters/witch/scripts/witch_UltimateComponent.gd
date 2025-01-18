extends Node2D
class_name Witch_UltimateComponent

@export var FrostNovaScene: PackedScene
@export var sfx_FrostNova: AudioStream

@onready var character: Character = owner
@onready var PlayerInfo: PlayerInfoResource
@onready var AM: Witch_AbilityManager = get_parent()

func _process(delta: float) -> void:
	#raise_charge(delta)
	
	if not character.enabled:
		PlayerInfo.ult_need_circle_aim = false
		return
	
	if character.stats.charge >= character.stats.max_charge:
		PlayerInfo.ult_need_circle_aim = true
		character.wpn.modulate = Color(0.5, 2, 2)
		if PlayerInfo.input_ult:
			character.sprite_look_at(PlayerInfo.mouse_direction)
		if Input.is_action_just_released("right_click"): # this the best way
			spend_charge()
			character.wpn.modulate = Color(1, 1, 1)
	

func spawn_area_effect(area_effect: PackedScene, target_pos: Vector2) -> void:
	assert(area_effect, "missing proj")
	SoundPlayer.play_sound_2D(target_pos, sfx_FrostNova, -10)
	
	var effect_instance: FrostStorm = area_effect.instantiate()
	effect_instance.global_position = target_pos
	effect_instance.size = AM.explosion_scale
	effect_instance.damage = AM.frost_storm_dmg
	effect_instance.max_spawn_counter = AM.explosion_num
	effect_instance.ep = character.stats.ep
	if AM.skill_ult_crystalize:
		effect_instance.debuff = CombatManager.Debuffs.CRYSTALIZED
	
	get_tree().root.add_child(effect_instance)

func raise_charge(delta: float) -> void:
	var s: CharacterStats = character.stats
	s.charge = min(s.max_charge, s.charge + (
			s.base_charge_rate * (s.chr/100) * delta))


func spend_charge() -> void:
	spawn_area_effect(FrostNovaScene, get_global_mouse_position())
	character.stats.charge = 0
