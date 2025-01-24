extends Character_AbilityManager
class_name Rogue_AbilityManager

## public properties used by child components
# atk comp
var fire_blade_bullet_properties := BulletProperties.new()
var melee_hit_explosion_properties := ExplosionProperties.new()
# ult comp
var flame_eruption_properties := ExplosionProperties.new()

## names
var _basic_atk_name: String = "Fireblade Slash"
var _ult_name: String = "Eruption"

## Basic atk properties
var _max_distance: float = 275
var _bullet_speed: float = 400

var _melee_base_size: float = 1
var _melee_scale_size: float = 0.25

var _melee_base_percent: float = 1.5 ## percentages
var _ranged_base_percent: float = 1

var _zero_ammo_base_percent: float = 0.5

## Ult properties
var _ult_base_size: float = 1
var _ult_scale_size: float = 0.25

var _ult_base_percent: float = 3

var _ult_base_atk_buff: float = 0.75
var _ult_scale_atk_buff: float = 0.2

## Stats scaling
var _atk_scale: float = 4

## Final values
var _melee_size: float = _melee_base_size
var _melee_dmg: float
var _ranged_dmg: float

var _ult_size: float = _ult_base_size # final
var _ult_dmg: float # final
var _ult_atk_buff: float # final

## variables to make skill tree easier to track:
@onready var lvl_basicAtk_size_atk: int:
	set(lvl):
		var base_atk: float = stats.atk - _atk_scale * lvl_basicAtk_size_atk
		lvl_basicAtk_size_atk = lvl
		stats.atk = base_atk + (_atk_scale * lvl)
		_update_damage() ## should probably signal this...
		_melee_size = _melee_base_size + (_melee_scale_size * lvl)

@onready var lvl_ult_radius: int:
	set(lvl):
		lvl_ult_radius = lvl
		_ult_size = _ult_base_size + (_ult_scale_size * lvl)

@onready var lvl_ult_buff: int:
	set(lvl):
		lvl_ult_buff = lvl
		_ult_atk_buff = (_ult_base_atk_buff + (_ult_scale_atk_buff * lvl)) * stats.atk


func _update_skills() -> void:
	lvl_basicAtk_size_atk 	= StreeModel.left_nodes[2].lvl
	lvl_ult_radius 			= StreeModel.right_nodes[1].lvl
	lvl_ult_buff 			= StreeModel.right_nodes[3].lvl

	if BasicAttack is Rogue_AttackComponent:
		var atk_comp: Rogue_AttackComponent = BasicAttack
		atk_comp.extra_energy_enabled 	= StreeModel.left_nodes[1].lvl
		atk_comp.can_fire_at_zero_ammo 	= StreeModel.left_nodes[3].lvl
		print_debug(atk_comp.can_fire_at_zero_ammo)
	if Ultimate is Rogue_UltComponent:
		var ult_comp: Rogue_UltComponent = Ultimate
		ult_comp.extra_energy_enabled = StreeModel.right_nodes[2].lvl

#region: initalize model
func _initialize_model() -> void:
	## description of char
	StreeModel.root_node.name = "Cinder Rogue" ## more detailed name purely for stree
	StreeModel.root_node.description = "A spellblade from Flameheart Volcano, equipped with a burning sword." \
+ "\n\nDenizens of Flameheart utilize both weapon and magic in their fighting style to imitate the dance" \
+ " of the extinct Draconis." \
+ "\n\nElement: Fire"
	
	## char's basic atk nodes -----------------------------------------------------
	StreeModel.left_nodes[0].name = _basic_atk_name
	StreeModel.left_nodes[0].description = """Perform a sword slash with %d%% base damage. 
\nWhen slashing with ammo, the attack also launches a projectile which deals %d%% base damage.""" % (
		[_melee_base_percent * 100, _ranged_base_percent * 100]
	)
	
	StreeModel.left_nodes[1].name = "Way of the Sword"
	StreeModel.left_nodes[1].description = "Successful melee hits now generate extra energy"
	StreeModel.left_nodes[1].cost = 400
	
	StreeModel.left_nodes[2].name = "Sword Flow"
	StreeModel.left_nodes[2].description = """Every upgrade increases the size of melee swings by %d%%.
\nAdditionally, ATK is increased by %d.""" % (
		[_melee_scale_size * 100, _atk_scale]
	)
	StreeModel.left_nodes[2].max_lvl = 3
	StreeModel.left_nodes[2].cost = 750
	
	StreeModel.left_nodes[3].name = "Fervour"
	StreeModel.left_nodes[3].description = """At 0 ammo, basic attacks launch a weaker projectile that deals %d%% damage.""" % (
		[_zero_ammo_base_percent * 100]
	)
	StreeModel.left_nodes[3].cost = 3000
	
	## char's ult nodes -----------------------------------------------------
	StreeModel.right_nodes[0].name = _ult_name
	StreeModel.right_nodes[0].description = """Use ultimate to unleash an explosion around the character, dealing %d%% damage. 
The explosion destroys projectiles and gives a 10 second flat ATK buff for all teammates.
\nATK buff: %d%% of the Rogue's ATK stat""" % (
		[_ult_base_percent * 100, _ult_base_atk_buff * 100]
	)
	
	StreeModel.right_nodes[1].name = "Larger Eruption"
	StreeModel.right_nodes[1].description = """Each level increases the eruption size by %d%%.""" % (
		[_ult_scale_size * 100]
	)
	StreeModel.right_nodes[1].max_lvl = 3
	StreeModel.right_nodes[1].cost = 300
	
	StreeModel.right_nodes[2].name = "Hungry Flames"
	StreeModel.right_nodes[2].description = """Generate extra energy for every projectile destroyed or enemy hit by the explosion."""
	StreeModel.right_nodes[2].cost = 1000
	
	StreeModel.right_nodes[3].name = "Burning Ardor"
	StreeModel.right_nodes[3].description = """Each level increases the ATK buff of the ultimate by %d%%.""" % (
		[_ult_scale_atk_buff * 100]
	)
	StreeModel.right_nodes[3].max_lvl = 3
	StreeModel.right_nodes[3].cost = 2500
#endregion

func _update_properties() -> void:
	fire_blade_bullet_properties.final_damage =  _ranged_dmg
	fire_blade_bullet_properties. max_distance = _max_distance
	fire_blade_bullet_properties.speed 		= _bullet_speed
	fire_blade_bullet_properties.ep 		= stats.ep

	melee_hit_explosion_properties.final_damage = _melee_dmg
	melee_hit_explosion_properties.size 	= _melee_size
	melee_hit_explosion_properties.ep 		= stats.ep

	flame_eruption_properties.final_damage = _ult_dmg
	flame_eruption_properties.size 		= _ult_size
	flame_eruption_properties.ep 		= stats.ep

	if Ultimate is Rogue_UltComponent:
		var ult_comp: Rogue_UltComponent = Ultimate
		ult_comp.flame_eruption_properties = flame_eruption_properties
		ult_comp.ult_atk_buff = _ult_atk_buff

	if BasicAttack is Rogue_AttackComponent:
		var atk_comp: Rogue_AttackComponent = BasicAttack
		atk_comp.zero_ammo_damage_multiplier = _zero_ammo_base_percent
		atk_comp.fire_blade_bullet_properties = fire_blade_bullet_properties
		atk_comp.melee_hit_explosion_properties = melee_hit_explosion_properties

func _update_damage() -> void:
	_melee_dmg = _compute_damage(_melee_base_percent, 
			0, 1, stats)
	_ranged_dmg = _compute_damage(_ranged_base_percent,
			0, 1, stats)
	_ult_dmg = _compute_damage(_ult_base_percent,
			0, 1, stats)
	_ult_atk_buff = (_ult_base_atk_buff + (_ult_scale_atk_buff * lvl_ult_buff)
			) * stats.atk
