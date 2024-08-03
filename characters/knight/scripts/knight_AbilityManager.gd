extends Node2D
class_name Knight_AbilityManager

## AM stores projectile stats and properties

## single "" include newlines (shift enter's counted as \n)
## triple """""" allow verbatim newlines (shift enter's are nto counted as \n)

const StreeModel: SkillTreeModel = preload("res://characters/knight/knight_stree_model.tres")

@onready var character: Character = owner
@onready var PlayerInfo: PlayerInfoResource = character.PlayerInfo
@onready var stats: CharacterStats = character.stats

## components:
@onready var BasicAttack: Knight_AttackComponent = $BasicAttack
@onready var Ultimate: Knight_UltimateComponent = $Ultimate
@onready var Ammo: Knight_AmmoComponent = $Ammo

## Basic atk properties
var bullet_speed: float = 450
var max_distance: float = 300

var base_percent_basic_bolt: float = 1
var base_percent_lightning_bolt: float = 1.5

var scale_percent_basic_bolt: float = 0
var scale_percent_lightning_bolt: float = 0.4

## Ult properties
var ult_bullet_speed: float = 600
var ult_max_distance: float = 800

var base_ult_percent_tier1: float = 3 ## tier 2 gives "shotgun" effect

var scale_ult_percent_tier1: float = 0.4

## Stats scaling
@onready var base_max_ammo: int = stats.MAX_AMMO ## MUST NOT BE CHANGED AGAIN
var scale_ammo: int = 2
@onready var base_CHR: float = stats.CHR
var scale_CHR: float = 10 ## charge rate

## Final Computations
var damage_lightning_bolt: float
var damage_basic_bolt: float

var ult_damage_tier1: float

## variables to make skill tree easier to track:
@onready var level_basicAtk_ammo: int = 0:
	set(level):
		level_basicAtk_ammo = level
		stats.MAX_AMMO = base_max_ammo + (scale_ammo * level)

@onready var level_basicAtk_upgrade: int = 0:
	set(level):
		level_basicAtk_upgrade = level
		damage_lightning_bolt = compute(base_percent_lightning_bolt, scale_percent_lightning_bolt, level)
		damage_basic_bolt = compute(base_percent_basic_bolt, 0, level)

@onready var level_ult_upgrade: int = 0:
	set(level):
		level_ult_upgrade = level
		stats.MAX_CHARGE = 50 + (50 * min(level, 1))
		ult_damage_tier1 = compute(base_ult_percent_tier1, scale_ult_percent_tier1, level)
		if level == 1:
			character.stats.charge_tier = stats.charge_tiers.TWO
		else:
			character.stats.charge_tier = stats.charge_tiers.ONE

@onready var level_ult_chargeRate: int = 0:
	set(level):
		level_ult_chargeRate = level
		stats.CHR = base_CHR + (scale_CHR * level)

var skill_ult_missile: bool = false
var skill_basicAtk_double: bool = false


func _ready() -> void:
	BasicAttack.PlayerInfo = character.PlayerInfo
	Ultimate.PlayerInfo = character.PlayerInfo
	Ammo.PlayerInfo = character.PlayerInfo
	
	initialize_model()
	StreeModel.skill_node_bought.connect(update_skills)
	PlayerInfo.changed_buff_raw_atk.connect(update_damage)
	update_damage()


func update_skills() -> void:
	level_basicAtk_ammo = StreeModel.left_nodes[1].lvl
	level_basicAtk_upgrade = StreeModel.left_nodes[2].lvl
	
	level_ult_upgrade = StreeModel.right_nodes[1].lvl
	level_ult_chargeRate = StreeModel.right_nodes[3].lvl
	
	# boolean from int, 0 = false, 1 = true
	skill_ult_missile = StreeModel.right_nodes[2].lvl
	skill_basicAtk_double = StreeModel.left_nodes[3].lvl


#region Initialize Model
func initialize_model() -> void:
	## description of char
	StreeModel.root_node.name = "Infantry Knight"
	StreeModel.root_node.description = """An infantry soldier wielding a rapid-fire crossbow.
\nHailing from the City of Light, these lightning knights pave the way for technology in a world dominated by magic.
\nElement: Lightning"""
	
	## char's basic atk nodes -----------------------------------------------------
	StreeModel.left_nodes[0].name = "Rapid-fire Crossbow"
	StreeModel.left_nodes[0].description = """Hold left click to fire lightning bolts with %d%% base damage. 
\nRequires ammo which reloads overtime.""" % (
		[base_percent_basic_bolt * 100]
	)
	
	StreeModel.left_nodes[1].name = "More ammo"
	StreeModel.left_nodes[1].description = "Each level increases max ammo count by %d." % (
		[scale_ammo]
	)
	StreeModel.left_nodes[1].max_lvl = 3
	StreeModel.left_nodes[1].cost = 200
	
	StreeModel.left_nodes[2].name = "Burst shot"
	StreeModel.left_nodes[2].description = "Every 3rd shot shoots an enhanced lightning bolts with %d%% base damage.
\nEach upgrade increases damage of enhanced lightning bolts by %d%%." % (
		[base_percent_lightning_bolt * 100, scale_percent_lightning_bolt * 100]
	)
	StreeModel.left_nodes[2].max_lvl = 3
	StreeModel.left_nodes[2].cost = 800
	
	StreeModel.left_nodes[3].name = "Double shot"
	StreeModel.left_nodes[3].description = """Every shot now fires 2 bullets, ammo is unaffected.
\nAlso works with Burst shot."""
	StreeModel.left_nodes[3].cost = 5000
	
	## char's ult nodes -----------------------------------------------------
	StreeModel.right_nodes[0].name = "Grand Ballista"
	StreeModel.right_nodes[0].description = """Ultimate Type: Charge
\nHold down right click until you reach a charge tier (50, 100) then let go to fire a Grand Bolt with %d%% base damage.
\nHas a base charge rate of %d%%
""" % (
		[base_ult_percent_tier1 * 100, stats.CHR]
	)
	
	StreeModel.right_nodes[1].name = "2nd Tier Upgrade"
	StreeModel.right_nodes[1].description = """
Adds a 2nd charge tier which fires 3 enhanced lightning bolts along with the Grand Bolt."""
	StreeModel.right_nodes[1].cost = 400
	
	StreeModel.right_nodes[2].name = "Missile volley"
	StreeModel.right_nodes[2].description = """Bonus Effect: Charged shots also fire a volley of homing missiles with %d%% base damage. 
\nHigher charge tiers fire more missiles.""" % (
		[base_percent_basic_bolt * 100]
	)
	StreeModel.right_nodes[2].cost = 3000
	
	StreeModel.right_nodes[3].name = "Faster charge rate"
	StreeModel.right_nodes[3].description = """Each level increases charge rate by %d.""" % (
		[scale_CHR]
	)
	StreeModel.right_nodes[3].max_lvl = 3
	StreeModel.right_nodes[3].cost = 700
#endregion


func compute(base: float, scaling: float, level: int) -> float:
	var raw_output: float = (stats.ATK + PlayerInfo.buff_raw_atk) * (base 
		+ scaling * max(0, level - 1))
	
	return raw_output
	

func update_damage() -> void:
	damage_lightning_bolt = compute(base_percent_lightning_bolt, scale_percent_lightning_bolt, level_basicAtk_upgrade)
		
	damage_basic_bolt = compute(base_percent_basic_bolt, 0, 1)
	
	ult_damage_tier1 = compute(base_ult_percent_tier1, 0, level_ult_upgrade)
