extends Node2D
class_name Rogue_AbilityManager

var StreeModel: SkillTreeModel = preload("res://characters/rogue/rogue_stree_model.tres")

## names
var _basic_atk_name: String = "Fireblade Slash"
var _ult_name: String = "Eruption"

## Basic atk properties
var melee_size_base: float = 1
var melee_size_scale: float = 0.25
var melee_size: float = melee_size_base # final

var melee_extra_energy_enabled: bool = false

var base_melee_dmg: float = 1.5 ## percentages
var melee_dmg: float # final

var ranged_max_distance: float = 275
var bullet_speed: float = 400

var base_ranged_dmg: float = 1
var ranged_dmg: float # final

var zero_ammo_atk_enabled: bool = false # stree node
var base_zero_ammo_ranged_dmg: float = 0.4
var zero_ammo_ranged_dmg: float = base_zero_ammo_ranged_dmg # final

## Ult properties
var ult_size_base: float = 1
var ult_size_scale: float = 0.25
var ult_size: float = ult_size_base # final

var ult_extra_energy_enabled: bool = false ## stree node

var base_ult_dmg: float = 3
var ult_dmg: float # final

var ult_atk_buff_base: float = 0.75
var ult_atk_buff_scale: float = 0.2
var ult_atk_buff: float # final

@onready var character: Character = owner
@onready var PlayerInfo: PlayerInfoResource = character.PlayerInfo
@onready var stats: CharacterStats = character.stats

## Components:
@onready var BasicAttack: Rogue_AttackComponent = $BasicAttack
@onready var Ultimate: Rogue_UltimateComponent = $Ultimate
@onready var Ammo: Rogue_AmmoComponent = $Ammo

## Stats scaling
var scale_atk: float = 4

## variables to make skill tree easier to track:
@onready var lvl_basicAtk_size_atk: int:
	set(lvl):
		var base_atk: float = stats.ATK - scale_atk * lvl_basicAtk_size_atk
		lvl_basicAtk_size_atk = lvl
		stats.ATK = base_atk + (scale_atk * lvl)
		update_damage() ## should probably signal this...
		melee_size = melee_size_base + (melee_size_scale * lvl)

@onready var lvl_ult_radius: int:
	set(lvl):
		lvl_ult_radius = lvl
		ult_size = ult_size_base + (ult_size_scale * lvl)

@onready var lvl_ult_buff: int:
	set(lvl):
		lvl_ult_buff = lvl
		ult_atk_buff = (ult_atk_buff_base + (ult_atk_buff_scale * lvl)) * stats.ATK



func _ready() -> void:
	BasicAttack.PlayerInfo = character.PlayerInfo
	Ultimate.PlayerInfo = character.PlayerInfo
	Ammo.PlayerInfo = character.PlayerInfo
	
	EventBus.returned_to_mainhub.connect(_reset_ability_manager)
	## unique to rogue
	EventBus.energy_gen_from_enemy_got_hit.connect(energy_production)
	EventBus.energy_gen_from_skills.connect(energy_production)
	
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
	melee_extra_energy_enabled = StreeModel.left_nodes[1].lvl
	lvl_basicAtk_size_atk = StreeModel.left_nodes[2].lvl
	zero_ammo_atk_enabled = StreeModel.left_nodes[3].lvl
	
	lvl_ult_radius = StreeModel.right_nodes[1].lvl
	ult_extra_energy_enabled = StreeModel.right_nodes[2].lvl
	lvl_ult_buff = StreeModel.right_nodes[3].lvl


func initialize_model() -> void:
	## description of char
	StreeModel.root_node.name = "Cinder Rogue" ## more detailed name purely for stree
	StreeModel.root_node.description = "A spellblade from Flameheart Volcano, equipped with a burning sword." \
+ "\n\nDenizens of Flameheart utilize both weapon and magic in their fighting style to imitate the dance" \
+ " of the extinct Draconis." \
+ "\n\nElement: Fire"
	
	## char's basic atk nodes -----------------------------------------------------
	StreeModel.left_nodes[0].name = _basic_atk_name
	StreeModel.left_nodes[0].description = """Hold left click to perform a sword slash with %d%% base damage. 
\nWhen slashing with ammo, the attack also launches a projectile which deals %d%% base damage.
\nYou can attack even with 0 ammo, but ammo only regenerates when you're not attacking.""" % (
		[base_melee_dmg * 100, base_ranged_dmg * 100]
	)
	
	StreeModel.left_nodes[1].name = "Way of the Sword"
	StreeModel.left_nodes[1].description = "Successful melee hits now generate extra energy"
	StreeModel.left_nodes[1].cost = 400
	
	StreeModel.left_nodes[2].name = "Sword Flow"
	StreeModel.left_nodes[2].description = """Every upgrade increases the size of melee swings by %d%%.
\nAdditionally, ATK is increased by %d.""" % (
		[melee_size_scale * 100, scale_atk]
	)
	StreeModel.left_nodes[2].max_lvl = 3
	StreeModel.left_nodes[2].cost = 750
	
	StreeModel.left_nodes[3].name = "Fervour"
	StreeModel.left_nodes[3].description = """At 0 ammo, basic attacks launch a weaker projectile that deals %d%% damage.""" % (
		[base_zero_ammo_ranged_dmg * 100]
	)
	StreeModel.left_nodes[3].cost = 3000
	
	## char's ult nodes -----------------------------------------------------
	StreeModel.right_nodes[0].name = _ult_name
	StreeModel.right_nodes[0].description = """Ultimate Type: Energy
\nAt full energy, press right click to unleash an explosion around the character, dealing %d%% damage. 
The explosion destroys projectiles and gives a 10 second flat ATK buff for all teammates.
\nATK buff: %d%% of the Rogue's ATK stat
\nEnergy is gained by damaging enemies. Charge rate increases the gain in energy.""" % (
		[base_ult_dmg * 100, ult_atk_buff_base * 100]
	)
	
	StreeModel.right_nodes[1].name = "Larger Eruption"
	StreeModel.right_nodes[1].description = """Each level increases the eruption size by %d%%.""" % (
		[ult_size_scale * 100]
	)
	StreeModel.right_nodes[1].max_lvl = 3
	StreeModel.right_nodes[1].cost = 300
	
	StreeModel.right_nodes[2].name = "Hungry Flames"
	StreeModel.right_nodes[2].description = """Generate extra energy for every projectile destroyed or enemy hit by the explosion."""
	StreeModel.right_nodes[2].cost = 1000
	
	StreeModel.right_nodes[3].name = "Burning Ardor"
	StreeModel.right_nodes[3].description = """Each level increases the ATK buff of the ultimate by %d%%.""" % (
		[ult_atk_buff_scale * 100]
	)
	StreeModel.right_nodes[3].max_lvl = 3
	StreeModel.right_nodes[3].cost = 2500
#endregion


func update_damage() -> void:
	melee_dmg = AbilityHelper.compute_damage(base_melee_dmg, 
			0, 1, stats)
	
	ranged_dmg = AbilityHelper.compute_damage(base_ranged_dmg,
			0, 1, stats)
	
	zero_ammo_ranged_dmg = AbilityHelper.compute_damage(base_zero_ammo_ranged_dmg,
			0, 1, stats)
	
	ult_dmg = AbilityHelper.compute_damage(base_ult_dmg,
			0, 1, stats)
	
	ult_atk_buff = (ult_atk_buff_base + (ult_atk_buff_scale * lvl_ult_buff)
			) * stats.ATK


func energy_production(procs: float) -> void:
	if not character:
		push_error("ERROR ON %s AM" % name)
		return
	
	#var base_energy_prod: float = 1 + stats.CHR/50
	#print("procs = %0.2f" % (base_energy_prod * procs))
	var s: CharacterStats = character.stats
	s.charge = clampf(s.charge + s.base_charge_rate * (s.CHR/100) * procs,
			0,
			s.MAX_CHARGE)
	## every enemy death gives 3 proc
	## every enemy hit gives 0.5 proc
