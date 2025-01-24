extends Node2D
class_name Character_AbilityManager

@export var StreeModel: SkillTreeModel

## every AM needs these
@onready var character: Character = owner
@onready var PlayerInfo: PlayerInfoResource = character.PlayerInfo
@onready var stats: CharacterStats = character.stats

## components:
@onready var BasicAttack: 	Character_AttackComponent = $BasicAttack
@onready var Ultimate: 		Character_UltComponent 	= $Ultimate
@onready var Ammo: 			Character_AmmoComponent = $Ammo

## TODO: make these 2 functions common to all ability managers
func _ready() -> void:
	assert(StreeModel, "Missing Stree for %s" % name)
	BasicAttack.PlayerInfo = character.PlayerInfo
	Ultimate.PlayerInfo = character.PlayerInfo
	Ammo.PlayerInfo = character.PlayerInfo
	
	## Energy regen
	EventBus.energy_gen_from_enemy_got_hit.connect(_on_energy_gen)
	EventBus.energy_gen_from_skills.connect(_on_energy_gen)
	
	EventBus.returned_to_mainhub.connect(_reset_ability_manager)
	StreeModel.skill_node_bought.connect(_update_skills)
	PlayerInfo.changed_buff_raw_atk.connect(_update_damage_and_properties)
	stats.stats_changed.connect(_update_damage_and_properties)
	
	Ultimate.charge_spent.connect(_on_charge_spent)

	_initialize_model()
	_update_skills()
	_update_damage_and_properties()

func _reset_ability_manager() -> void:
	for i in range(1, StreeModel.left_nodes.size()):
		StreeModel.left_nodes[i].lvl = 0
	for i in range(1, StreeModel.right_nodes.size()):
		StreeModel.right_nodes[i].lvl = 0
	_initialize_model()
	_update_skills()
	_update_damage_and_properties()

func _update_damage_and_properties() -> void:
	_update_damage()
	_update_properties()

func _update_skills() -> void:
	## modify this
	pass

func _initialize_model() -> void:
	## description of char, modify this
	pass

func _update_properties() -> void:
	## modify this
	pass

func _update_damage() -> void:
	## modify this
	pass

func _compute_damage(base: float, scaling: float, level: int, stats: CharacterStats) -> float:
	var output: float = (stats.atk + PlayerInfo.buff_raw_atk) * (base 
		+ scaling * max(0, level - 1))
	return output

func _on_charge_spent(used_charge: float) -> void:
	stats.charge -= used_charge

func _on_energy_gen(procs: float) -> void:
	if not character:
		push_error("ERROR ON %s AM" % name)
		return
	
	var new_charge: float = stats.charge + stats.base_charge_rate * (stats.chr/100) * procs
	stats.charge = new_charge
	Ultimate.update_charge(stats.charge, stats.charge_threshold, stats.charge_tiers)
