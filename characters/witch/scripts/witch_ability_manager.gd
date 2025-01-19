extends Character_AbilityManager
class_name Witch_AbilityManager

## public properties used by child components
var ult_explosion_properties := ExplosionProperties.new()	## frost storm
var ice_spike_bullet_properties := BulletProperties.new()

## Basic atk properties
var _bullet_speed: float = 375
var _max_distance: float = 260
var _ice_spike_base_percent: float = 1
var _icicle_dmg_scaling: float = 0.3

## Ult properties
var _ult_base_percent: float = 0.7
var _ult_base_explosion_count: int = 15
var _ult_base_size: float = 1

var _ult_scale_explosion_count: int = 3
var _ult_scale_size: float = 25 # adds to scale

## Stats scaling
@onready var _base_reload_time: float = stats.reload_time
var _scale_reload_time: float = 0.1 ## subtracts from base reload time, to speed it up

## Final Computations
var _final_explosion_count: int = _ult_base_explosion_count
var _final_explosion_size: float = _ult_base_size
var _ice_spike_dmg: float
var _ult_dmg: float

@onready var level_basicAtk_reload: int = 0:
	set(lvl):
		level_basicAtk_reload = lvl
		Ammo.t_ammo_regen.wait_time = _base_reload_time - (
			_base_reload_time * _scale_reload_time * lvl)

@onready var level_ult_explosions: int = 0:
	set(lvl):
		level_ult_explosions = lvl
		_final_explosion_count = _ult_base_explosion_count + (
			_ult_scale_explosion_count * lvl)

@onready var level_ult_size: int = 0:
	set(lvl):
		level_ult_size = lvl
		_final_explosion_size = _ult_base_size + (
			_ult_scale_size/100.0 * lvl)

func _update_skills() -> void:
	level_basicAtk_reload = StreeModel.left_nodes[1].lvl
	
	level_ult_explosions = StreeModel.right_nodes[1].lvl
	level_ult_size = StreeModel.right_nodes[2].lvl
	
	if BasicAttack is Witch_AttackComponent:
		var atk_comp: Witch_AttackComponent = BasicAttack
		atk_comp.can_crystalize = StreeModel.left_nodes[2].lvl
		atk_comp.second_icicle_enabled = StreeModel.left_nodes[3].lvl
	
	if Ultimate is Witch_UltComponent:
		var ult_comp: Witch_UltComponent = Ultimate
		ult_comp.can_crystalize = StreeModel.right_nodes[3].lvl


func _initialize_model() -> void:
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
			[_ice_spike_base_percent * 100, _icicle_dmg_scaling * 100]
		)
	
	StreeModel.left_nodes[1].name = "Pre-drawn Ice Spikes"
	StreeModel.left_nodes[1].description = """Each level decreases reload time by %.2f seconds""" % (
			[_scale_reload_time]
	)
	StreeModel.left_nodes[1].max_lvl = 3
	StreeModel.left_nodes[1].cost = 350
	
	StreeModel.left_nodes[2].name = "Crystalized Spikes"
	StreeModel.left_nodes[2].description = "Ice Spears and icicles now inflict a stack of crystalized.
\nCrystalized: Detonates at 9 stack or after 2.5 seconds
Each stack deals 5 damage, Every 3 stack increases final damage by 30%%"
	StreeModel.left_nodes[2].cost = 1400
	
	StreeModel.left_nodes[3].name = "Denser Icicles"
	StreeModel.left_nodes[3].description = "Icicles now explode twice. The second explosion has greater size."
	StreeModel.left_nodes[3].max_lvl = 1
	StreeModel.left_nodes[3].cost = 2800
	
	# char's ult nodes
	StreeModel.right_nodes[0].name = "Frost Storm"
	StreeModel.right_nodes[0].description = "Ultimate Type: Mana
\nPassively accumulates mana. At 50 mana, press right click to cast a Frost Storm in the target position. 
\nIce explosions from Frost Storm deals %d%% damage." % (
			[_ult_base_percent * 100]
	)
	
	StreeModel.right_nodes[1].name = "Longer Duration"
	StreeModel.right_nodes[1].description = "Each level increases number of ice explosions by %d" % (
			[_ult_scale_explosion_count]
	)
	StreeModel.right_nodes[1].max_lvl = 3
	StreeModel.right_nodes[1].cost = 300
	
	StreeModel.right_nodes[2].name = "Greater Frost Storm"
	StreeModel.right_nodes[2].description = "Each level increases size of ice explosion by %d%%" % (
			[_ult_scale_size]
	)
	StreeModel.right_nodes[2].max_lvl = 3
	StreeModel.right_nodes[2].cost = 1000
	
	StreeModel.right_nodes[3].name = "Crystalized Storm"
	StreeModel.right_nodes[3].description = "Explosions from Frost Storm now inflict a stack of crystalized.
\nCrystalized: Detonates at 9 stack or after 2.5 seconds
Each stack deals 5 damage, Every 3 stack increases final damage by 30%%"
	StreeModel.right_nodes[3].cost = 2000
	### might wanna have this scale from EP

func _update_properties() -> void:
	ice_spike_bullet_properties.final_damage =  _ice_spike_dmg
	ice_spike_bullet_properties. max_distance = _max_distance
	ice_spike_bullet_properties.speed = _bullet_speed
	ice_spike_bullet_properties.ep = stats.ep

	ult_explosion_properties.final_damage = _ult_dmg
	ult_explosion_properties.size = _final_explosion_size
	ult_explosion_properties.ep = stats.ep

	if Ultimate is Witch_UltComponent:
		var ult_comp: Witch_UltComponent = Ultimate
		ult_comp.ult_explosion_properties = ult_explosion_properties
		ult_comp.explosion_count = _final_explosion_count

	if BasicAttack is Witch_AttackComponent:
		var atk_comp: Witch_AttackComponent = BasicAttack
		atk_comp.ice_spike_bullet_properties = ice_spike_bullet_properties
		atk_comp.icicle_dmg_scaling = _icicle_dmg_scaling


func _update_damage() -> void:
	_ice_spike_dmg = _compute_damage(_ice_spike_base_percent, 
			0, 0, stats)
	_ult_dmg = _compute_damage(_ult_base_percent,
			0, 0, stats)
