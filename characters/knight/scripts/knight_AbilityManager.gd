extends Node2D
class_name Knight_AbilityManager

## AM stores projectile stats and properties

## single "" include newlines (shift enter's counted as \n)
## triple """""" allow verbatim newlines (shift enter's are not counted as \n)

var StreeModel: SkillTreeModel = preload("res://characters/knight/knight_stree_model.tres")

## names
var _basic_atk_name: String = "Rapidfire Crossbow"
var _ult_name: String = "Grand Ballista"

## Base bullet properties
var _bullet_speed: float = 450
var _max_distance: float = 300

var _basic_bullet_base_percent: float = 1
var _enhanced_bullet_base_percent: float = 1.5
var _enhanced_bullet_scale_percent: float = 0.5
var _ult_base_percent: float = 3.5 ## tier 2 gives "shotgun" effect

var _chr_scale: float = 10 ## charge rate
var _ammo_scale: int = 2

## public properties used by child components
var ult_bullet_properties := BulletProperties.new()
var basic_bullet_properties := BulletProperties.new()
var enhanced_bullet_properties := BulletProperties.new()
var missile_bullet_properties := BulletProperties.new()

## Final Computations
var _enhanced_bullet_damage: float
var _basic_bullet_damage: float
var _ult_damage: float

# var skill_ult_missile: bool = false ## right node 2A
# var skill_basicAtk_double: bool = false ## right node 2A

@onready var character: Character = owner
@onready var PlayerInfo: PlayerInfoResource = character.PlayerInfo
@onready var stats: CharacterStats = character.stats

## components:
@onready var BasicAttack: Knight_AttackComponent = $BasicAttack
@onready var Ultimate: Knight_UltimateComponent = $Ultimate
@onready var Ammo: Knight_AmmoComponent = $Ammo

## stats scaling (i need += so no more of this)

## variables to make skill tree easier to track:
@onready var level_basicAtk_ammo: int = 0: ## left node 1
	set(level):
		if level > level_basicAtk_ammo:
			level_basicAtk_ammo = level
			stats.max_ammo += _ammo_scale

@onready var level_basicAtk_burst: int = 0: ## left node 2B
	set(level):
		level_basicAtk_burst = level
		_update_damage()

@onready var level_ult_upgrade: int = 0: ## right node 1
	set(level):
		level_ult_upgrade = level
		stats.max_charge = stats.INITIAL_MAX_CHARGE + (
				stats.INITIAL_MAX_CHARGE * min(level, 1)
		)
		_update_damage()

@onready var level_ult_chargeRate: int = 0: ## right node 2B
	set(level):
		if level > level_ult_chargeRate:
			level_ult_chargeRate = level
			stats.chr += _chr_scale

## TODO: make these 2 functions common to all ability managers
func _ready() -> void:
	BasicAttack.PlayerInfo = character.PlayerInfo
	Ultimate.PlayerInfo = character.PlayerInfo
	Ammo.PlayerInfo = character.PlayerInfo
	
	## Energy regen
	EventBus.energy_gen_from_enemy_got_hit.connect(energy_production)
	EventBus.energy_gen_from_skills.connect(energy_production)
	
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
	level_basicAtk_ammo = StreeModel.left_nodes[1].lvl
	level_basicAtk_burst = StreeModel.left_nodes[2].lvl
	BasicAttack.enhanced_burst_shot_enabled = level_basicAtk_burst

	level_ult_upgrade = StreeModel.right_nodes[1].lvl
	level_ult_chargeRate = StreeModel.right_nodes[3].lvl
	
	# boolean from int, 0 = false, not 0 = true
	Ultimate.missiles_enabled = StreeModel.right_nodes[2].lvl
	BasicAttack.double_shot_enabled = StreeModel.left_nodes[3].lvl


#region Initialize Model
func _initialize_model() -> void:
	## description of char
	StreeModel.root_node.name = "Infantry Knight" ## more detailed name purely for stree
	StreeModel.root_node.description = "A soldier wielding a sophisticated crossbow inspired by" \
+ " the Spacefarers' non-magic weaponry." \
+ "\n\nHailing from the City of Light, these knights pave the way for technology in a world " \
+ "they deem too dependent on magic." \
+ "\n\nElement: Lightning"

	
	## char's basic atk nodes -----------------------------------------------------
	StreeModel.left_nodes[0].name = _basic_atk_name
	StreeModel.left_nodes[0].description = """Hold left click to fire lightning bolts with %d%% base damage. 
\nRequires ammo which reloads overtime.""" % (
		[_basic_bullet_base_percent * 100]
	)
	
	StreeModel.left_nodes[1].name = "More ammo"
	StreeModel.left_nodes[1].description = "Each level increases max ammo count by %d." % (
		[_ammo_scale]
	)
	StreeModel.left_nodes[1].max_lvl = 3
	StreeModel.left_nodes[1].cost = 200
	
	StreeModel.left_nodes[2].name = "Burst shot"
	StreeModel.left_nodes[2].description = "Every 3rd shot shoots an enhanced lightning bolts with %d%% base damage.
\nEach upgrade increases damage of enhanced lightning bolts by %d%%.
\nOn hit, the enhanced bolt releases a chain lightning that deals 20%% of the bolt's damage and targets up to 3 nearby enemies." % (
		[_enhanced_bullet_base_percent * 100, _enhanced_bullet_scale_percent * 100]
	)
	StreeModel.left_nodes[2].max_lvl = 3
	StreeModel.left_nodes[2].cost = 800
	
	StreeModel.left_nodes[3].name = "Double shot"
	StreeModel.left_nodes[3].description = """Every shot now fires 2 bullets, ammo is unaffected.
\nAlso works with Burst shot."""
	StreeModel.left_nodes[3].cost = 5000
	
	## char's ult nodes -----------------------------------------------------
	StreeModel.right_nodes[0].name = _ult_name
	StreeModel.right_nodes[0].description = """Ultimate Type: Charge
\nHold down right click until you reach a charge tier (50, 100) then let go to fire a Grand Bolt with %d%% base damage.
\nSpeed of charge depends on the character's Charge rate.
""" % (
		[_ult_base_percent * 100]
	)
	
	StreeModel.right_nodes[1].name = "2nd Tier Upgrade"
	StreeModel.right_nodes[1].description = """Adds a 2nd charge tier which fires 3 enhanced lightning bolts along with the Grand Bolt."""
	StreeModel.right_nodes[1].cost = 400
	
	StreeModel.right_nodes[2].name = "Missile volley"
	StreeModel.right_nodes[2].description = """Bonus Effect: Charged shots also fire a volley of homing missiles with %d%% base damage. 
\nHigher charge tiers fire more missiles.""" % (
		[_basic_bullet_base_percent * 100]
	)
	StreeModel.right_nodes[2].cost = 3000
	
	StreeModel.right_nodes[3].name = "Faster charge rate"
	StreeModel.right_nodes[3].description = """Each level increases charge rate by %d.""" % (
		[_chr_scale]
	)
	StreeModel.right_nodes[3].max_lvl = 3
	StreeModel.right_nodes[3].cost = 700
#endregion

func _update_properties() -> void:
	basic_bullet_properties.final_damage = _basic_bullet_damage
	basic_bullet_properties.max_distance = _max_distance
	basic_bullet_properties.speed = _bullet_speed
	basic_bullet_properties.ep = stats.ep

	enhanced_bullet_properties.final_damage = _enhanced_bullet_damage
	enhanced_bullet_properties.max_distance = _max_distance
	enhanced_bullet_properties.speed = _bullet_speed
	enhanced_bullet_properties.ep = stats.ep

	ult_bullet_properties.final_damage = _ult_damage
	ult_bullet_properties.max_distance =_max_distance * 3
	ult_bullet_properties.speed = _bullet_speed * 1.5
	ult_bullet_properties.ep = stats.ep

	missile_bullet_properties.final_damage = _basic_bullet_damage
	missile_bullet_properties.max_distance = _max_distance * 3
	missile_bullet_properties.speed = _bullet_speed * 0.5
	missile_bullet_properties.ep = stats.ep

	Ultimate.enhanced_bullet_properties = enhanced_bullet_properties
	Ultimate.ult_bullet_properties = ult_bullet_properties
	Ultimate.missile_bullet_properties = basic_bullet_properties

	BasicAttack.basic_bullet_properties = basic_bullet_properties
	BasicAttack.basic_bullet_properties = enhanced_bullet_properties

func _update_damage() -> void:
	_basic_bullet_damage = AbilityHelper.compute_damage(_basic_bullet_base_percent, 
			0, 1, stats)
	_enhanced_bullet_damage = AbilityHelper.compute_damage(_enhanced_bullet_base_percent, 
			_enhanced_bullet_scale_percent, level_basicAtk_burst, stats)	
	_ult_damage = AbilityHelper.compute_damage(_ult_base_percent, 
			0, level_ult_upgrade, stats)

func _on_charge_spent(used_charge: float) -> void:
	stats.charge -= used_charge

func energy_production(procs: float) -> void:
	if not character:
		push_error("ERROR ON %s AM" % name)
		return
	
	var new_charge: float = stats.charge + stats.base_charge_rate * (stats.chr/100) * procs
	stats.charge = new_charge
	Ultimate.update_charge(stats.charge, stats.charge_threshold, stats.charge_tier)
