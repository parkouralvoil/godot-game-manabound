extends Node2D
class_name Witch_AbilityManager

@onready var character: Character = owner
@onready var PlayerInfo: PlayerInfoResource = character.PlayerInfo
@onready var skill_tree: SkillTree = $SkillTree
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
@onready var base_charge_rate: float = stats.CHR # for witch, her charge rate remains da same

## Final Computations
var explosion_num: int = base_ult_explosions
var explosion_scale: float = base_ult_size

var frost_spike_dmg: float
var first_icicle_dmg: float
var second_icicle_dmg: float

var frost_storm_dmg: float

@onready var level_basicAtk_firerate: int = 0:
	set(lvl):
		level_basicAtk_firerate = lvl
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
	
	PlayerInfo.changed_buff_raw_atk.connect(update_damage)
	update_damage()


func stats_update() -> void:
	level_basicAtk_firerate = skill_tree.BasicAtk_array[1].level
	level_basicAtk_second_icicle = skill_tree.BasicAtk_array[2].level
	
	level_ult_explosions = skill_tree.Ult_array[1].level
	level_ult_size = skill_tree.Ult_array[2].level
	
	# boolean from int, 0 = false, 1 = true
	skill_ult_crystalize = skill_tree.Ult_array[3].level
	skill_basicAtk_crystalize = skill_tree.BasicAtk_array[3].level

func desc_update() -> void:
	## description of char
	skill_tree.root_node.skill_name = "Apprentice Witch"
	skill_tree.root_node.skill_desc = """A witch from Mana Haven, trained in the magic of Frost Art. 
\nFrost Art is a mystic art of mana imparted to the witches by the elves of the north. 
\nElement: Ice"""
	
	## char's basic atk nodes
	skill_tree.BasicAtk_array[0].skill_name = "Apprentice's Icestaff"
	skill_tree.BasicAtk_array[0].skill_desc = """Hold left click to fire ice spikes with %d%% base damage. 
\nThese spikes explode into icicles that deal %d%% base damage. 
\nAmmo takes longer to reload.""" % (
			[base_percent_frost_spear * 100, base_percent_1st_icicle * 100]
		)
	
	skill_tree.BasicAtk_array[1].skill_name = "Pre-drawn Frost Spikes"
	skill_tree.BasicAtk_array[1].skill_desc = """Each level decreases reload time by %.2f seconds""" % (
			[scale_reload_time]
	)
	
	skill_tree.BasicAtk_array[2].skill_name = "Greater Icicles"
	skill_tree.BasicAtk_array[2].skill_desc = "Icicles now explode for a 2nd time, dealing %d%% damage.
\nEach upgrade increases 1st icicle damage by %d%% and 2nd icicle damage by %d%%." % (
			[base_percent_2nd_icicle * 100, scale_percent_1st_icicle * 100, scale_percent_2nd_icicle * 100]
	)
	
	skill_tree.BasicAtk_array[3].skill_name = "Crystalized Spears"
	skill_tree.BasicAtk_array[3].skill_desc = "Cystalization: detonates at 9 stacks or after 5 seconds. 
\nEach stack deals 3 damage. 
\nEvery 3 stacks increases crystalization damage by 20%"
	
	# char's ult nodes
	skill_tree.Ult_array[0].skill_name = "Frost Storm"
	skill_tree.Ult_array[0].skill_desc = "Charge Type: Passive
\nPassively accumulates charge. At 50 charge, press right click to cast a Frost Storm in the target position. 
\nIce explosions from Frost Storm deals %d%% damage.
\nHas a base charge rate of %d%%" % (
			[base_ult_percent * 100, base_charge_rate]
	)
	
	skill_tree.Ult_array[1].skill_name = "Longer Duration"
	skill_tree.Ult_array[1].skill_desc = "Each level increases number of ice explosions by %d" % (
			[scale_ult_explosions]
	)
	
	skill_tree.Ult_array[2].skill_name = "Greater Frost Storm"
	skill_tree.Ult_array[2].skill_desc = "Each level increases size of ice explosion by %d%%" % (
			[scale_ult_size]
	)
	
	skill_tree.Ult_array[3].skill_name = "Crystalized Storm"
	skill_tree.Ult_array[3].skill_desc = "Ice explosions from Frost Storm now inflict a stack of crystalization.
\nCystalization: detonates at 9 stacks or after 5 seconds. 
\nEach stack deals 3 damage. 
\nEvery 3 stacks increases crystalization damage by 20%"
	## might wanna have this scale from EP

func compute(base: float, scaling: float, lvl: int) -> float:
	var raw_output: float = character.stats.ATK * (base + scaling * max(0, lvl - 1))
	return raw_output

func update_damage() -> void:
	frost_spike_dmg = compute(base_percent_frost_spear, 
			0, 0)
	
	first_icicle_dmg = compute(base_percent_1st_icicle, 
			scale_percent_1st_icicle, level_basicAtk_second_icicle,)
	
	second_icicle_dmg = compute(base_percent_2nd_icicle, 
			scale_percent_2nd_icicle, level_basicAtk_second_icicle,)
	
	frost_storm_dmg = compute(base_ult_percent,
			0, 0)
