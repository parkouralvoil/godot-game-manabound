extends Node2D
class_name Witch_AbilityManager

var StreeModel: SkillTreeModel = preload("res://characters/witch/witch_stree_model.tres")

@onready var character: Character = owner
@onready var PlayerInfo: PlayerInfoResource = character.PlayerInfo
@onready var stats: CharacterStats = character.stats

## components
@onready var BasicAttack: Witch_AttackComponent = $BasicAttack
@onready var Ultimate: Witch_UltimateComponent = $Ultimate
@onready var Ammo: Witch_AmmoComponent = $Ammo

## Basic atk properties
var bullet_speed: float = 375
var max_distance: float = 260
var base_percent_frost_spear: float = 1
var base_percent_1st_icicle: float = 0.5
var base_percent_2nd_icicle: float = 0.25

var scale_percent_1st_icicle: float = 0.3
var scale_percent_2nd_icicle: float = 0.15

## Ult properties
var base_ult_percent: float = 0.7
var base_ult_explosions: int = 15
var base_ult_size: float = 1

var scale_ult_explosions: int = 3
var scale_ult_size: float = 25 # adds to scale

## Stats scaling
@onready var base_reload_time: float = stats.reload_time
var scale_reload_time: float = 0.1 ## subtracts from base reload time, to speed it up
@onready var base_charge_rate: float = stats.chr # for witch, her charge rate remains da same

## Final Computations
var explosion_num: int = base_ult_explosions
var explosion_scale: float = base_ult_size

var frost_spike_dmg: float
var first_icicle_dmg: float
var second_icicle_dmg: float

var frost_storm_dmg: float

@onready var level_basicAtk_reload: int = 0:
	set(lvl):
		level_basicAtk_reload = lvl
		Ammo.t_ammo_regen.wait_time = base_reload_time - (
			base_reload_time * scale_reload_time * lvl)

@onready var level_basicAtk_second_icicle: int = 0:
	set(lvl):
		level_basicAtk_second_icicle = lvl
		update_damage()

@onready var level_ult_explosions: int = 0:
	set(lvl):
		level_ult_explosions = lvl
		explosion_num = base_ult_explosions + (
			scale_ult_explosions * lvl)

@onready var level_ult_size: int = 0:
	set(lvl):
		level_ult_size = lvl
		explosion_scale = base_ult_size + (
			scale_ult_size/100.0 * lvl)

var skill_ult_crystalize: bool = false
var skill_basicAtk_crystalize: bool = false


func _ready() -> void:
	BasicAttack.PlayerInfo = character.PlayerInfo
	Ultimate.PlayerInfo = character.PlayerInfo
	Ammo.PlayerInfo = character.PlayerInfo
	
	## unique to rogue
	EventBus.energy_gen_from_enemy_got_hit.connect(energy_production)
	EventBus.energy_gen_from_skills.connect(energy_production)
	
	EventBus.returned_to_mainhub.connect(_reset_ability_manager)
	StreeModel.skill_node_bought.connect(update_skills)
	PlayerInfo.changed_buff_raw_atk.connect(update_damage)
	stats.stats_changed.connect(update_damage)
	
	initialize_model()
	update_damage()


func _reset_ability_manager() -> void:
	for i in range(1, StreeModel.left_nodes.size()):
		StreeModel.left_nodes[i].lvl = 0
	for i in range(1, StreeModel.right_nodes.size()):
		StreeModel.right_nodes[i].lvl = 0
	initialize_model()
	update_damage()
	update_skills()


func update_skills() -> void:
	level_basicAtk_reload = StreeModel.left_nodes[1].lvl
	skill_basicAtk_crystalize = StreeModel.left_nodes[2].lvl
	level_basicAtk_second_icicle = StreeModel.left_nodes[3].lvl
	
	level_ult_explosions = StreeModel.right_nodes[1].lvl
	level_ult_size = StreeModel.right_nodes[2].lvl
	
	# boolean from int, 0 = false, 1 = true
	skill_ult_crystalize = StreeModel.right_nodes[3].lvl


func initialize_model() -> void:
	## description of char
	StreeModel.root_node.name = "Apprentice Witch"
	StreeModel.root_node.description = "A student from Mana Haven, trained in the magic of Frost Art." \
	+ "\n\nNorthern sages imparted their arts and teachings to the witches" \
	+ " to aid them in rebuilding a great empire ruined by spears of sky-rock.\n\nElement: Ice"

	
	## char's basic atk nodes
	StreeModel.left_nodes[0].name = "Apprentice's Icestaff"
	StreeModel.left_nodes[0].description = """Hold left click to fire ice spikes with %d%% base damage. 
\nThese spikes explode into icicles that deal %d%% base damage. 
\nAmmo takes longer to reload.""" % (
			[base_percent_frost_spear * 100, base_percent_1st_icicle * 100]
		)
	
	StreeModel.left_nodes[1].name = "Pre-drawn Frost Spikes"
	StreeModel.left_nodes[1].description = """Each level decreases reload time by %.2f seconds""" % (
			[scale_reload_time]
	)
	StreeModel.left_nodes[1].max_lvl = 3
	StreeModel.left_nodes[1].cost = 350
	
	StreeModel.left_nodes[2].name = "Crystalized Spears"
	StreeModel.left_nodes[2].description = "Ice Spears and icicles now inflict a stack of crystalized.
\nCrystalized: Detonates at 9 stack or after 2.5 seconds
Each stack deals 5 damage, Every 3 stack increases final damage by 30%%"
	StreeModel.left_nodes[2].cost = 1400
	
	StreeModel.left_nodes[3].name = "Denser Icicles"
	StreeModel.left_nodes[3].description = "Icicles now explode for a 2nd time, dealing %d%% damage.
\nEach upgrade increases 1st icicle damage by %d%% and 2nd icicle damage by %d%%." % (
			[base_percent_2nd_icicle * 100, scale_percent_1st_icicle * 100, scale_percent_2nd_icicle * 100]
	)
	StreeModel.left_nodes[3].max_lvl = 3
	StreeModel.left_nodes[3].cost = 2800
	
	# char's ult nodes
	StreeModel.right_nodes[0].name = "Frost Storm"
	StreeModel.right_nodes[0].description = "Ultimate Type: Mana
\nPassively accumulates mana. At 50 mana, press right click to cast a Frost Storm in the target position. 
\nIce explosions from Frost Storm deals %d%% damage." % (
			[base_ult_percent * 100]
	)
	
	StreeModel.right_nodes[1].name = "Longer Duration"
	StreeModel.right_nodes[1].description = "Each level increases number of ice explosions by %d" % (
			[scale_ult_explosions]
	)
	StreeModel.right_nodes[1].max_lvl = 3
	StreeModel.right_nodes[1].cost = 300
	
	StreeModel.right_nodes[2].name = "Greater Frost Storm"
	StreeModel.right_nodes[2].description = "Each level increases size of ice explosion by %d%%" % (
			[scale_ult_size]
	)
	StreeModel.right_nodes[2].max_lvl = 3
	StreeModel.right_nodes[2].cost = 1000
	
	StreeModel.right_nodes[3].name = "Crystalized Storm"
	StreeModel.right_nodes[3].description = "Explosions from Frost Storm now inflict a stack of crystalized.
\nCrystalized: Detonates at 9 stack or after 2.5 seconds
Each stack deals 5 damage, Every 3 stack increases final damage by 30%%"
	StreeModel.right_nodes[3].cost = 2000
	### might wanna have this scale from EP


func update_damage() -> void:
	frost_spike_dmg =  AbilityHelper.compute_damage(base_percent_frost_spear, 
			0, 0, stats)
	
	first_icicle_dmg =  AbilityHelper.compute_damage(base_percent_1st_icicle, 
			scale_percent_1st_icicle, level_basicAtk_second_icicle, stats)
	
	second_icicle_dmg =  AbilityHelper.compute_damage(base_percent_2nd_icicle, 
			scale_percent_2nd_icicle, level_basicAtk_second_icicle, stats)
	
	frost_storm_dmg =  AbilityHelper.compute_damage(base_ult_percent,
			0, 0, stats)


func energy_production(procs: float) -> void:
	if not character:
		push_error("ERROR ON %s AM" % name)
		return
	
	#var base_energy_prod: float = 1 + stats.chr/50
	#print("procs = %0.2f" % (base_energy_prod * procs))
	var s: CharacterStats = character.stats
	s.charge = clampf(s.charge + s.base_charge_rate * (s.chr/100) * procs,
			0,
			s.max_charge)
