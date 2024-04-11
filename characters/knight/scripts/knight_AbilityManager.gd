extends Node2D
class_name Knight_AbilityManager

# Character stores ammo, hp, max charge, current charge, charge rate
# AM stores projectile stats and properties

@onready var character: Character = owner
@onready var skill_tree: SkillTree = $SkillTree
@onready var Ammo: Knight_AmmoComponent = $Ammo

@export_category("basic atk: Base")
var bullet_speed: float = 400
var max_distance: float = 300
var base_percent_basic_bolt: float = 50
var base_percent_lightning_bolt: float = 80

@export_category("basic atk: Scaling")
var scale_percent_basic_bolt: float = 0
var scale_percent_lightning_bolt: float = 40

@export_category("ult: Base")
var ult_bullet_speed: float = 600
var ult_max_distance: float = 1000
var base_ult_percent_tier1: float = 200
var base_ult_percent_tier2: float = 250

@export_category("ult: Scaling")
var scale_ult_percent_tier1: int = 50
var scale_ult_percent_tier2: int = 75

@export_category("Stats")
# each char only has a specific upgrade for one stat, to ease building
var base_stat: int = 9
var scale_stat: int = 2
var base_charge_rate: int = 65
var scale_charge_rate: int = 25

# variables to store computations
var damage_lightning_bolt: float
var damage_basic_bolt: float

var ult_damage_tier1: float
var ult_damage_tier2: float

# variables to make skill tree easier to track:
var level_basicAtk_ammo: int = 0:
	set(lvl):
		level_basicAtk_ammo = lvl
		character.max_ammo = base_stat + (scale_stat * lvl)

var level_basicAtk_upgrade: int = 0:
	set(lvl):
		level_basicAtk_upgrade = lvl
		damage_lightning_bolt = compute(base_percent_lightning_bolt,
				scale_percent_lightning_bolt, lvl)
		damage_basic_bolt = compute(base_percent_basic_bolt, 0, lvl)

var level_ult_upgrade: int = 0:
	set(lvl):
		level_ult_upgrade = lvl
		character.max_charge = 50 + (50 * min(lvl, 1))
		ult_damage_tier1 = compute(base_ult_percent_tier1,
				scale_ult_percent_tier1, lvl)
		ult_damage_tier2 = compute(base_ult_percent_tier2,
				scale_ult_percent_tier2, lvl )

var level_ult_chargeRate: int = 0:
	set(lvl):
		level_ult_chargeRate = lvl
		character.charge_rate = base_charge_rate + (
				scale_charge_rate * lvl)

var skill_ult_missile: bool = false
var skill_basicAtk_double: bool = false


func stats_update() -> void:
	level_basicAtk_ammo = skill_tree.BasicAtk_array[1].level
	level_basicAtk_upgrade = skill_tree.BasicAtk_array[2].level
	
	level_ult_upgrade = skill_tree.Ult_array[1].level
	level_ult_chargeRate = skill_tree.Ult_array[3].level
	
	# boolean from int, 0 = false, 1 = true
	skill_ult_missile = skill_tree.Ult_array[2].level
	skill_basicAtk_double = skill_tree.BasicAtk_array[3].level

func desc_update() -> void:
	var data := get_txt_info()
	
	# description of char
	data.pop_front() # remove "knight"
	skill_tree.root_node.skill_name = data.pop_front()
	skill_tree.root_node.skill_desc = data.pop_front()
	
	# char's basic atk nodes
	skill_tree.BasicAtk_array[0].skill_name = data.pop_front()
	skill_tree.BasicAtk_array[0].skill_desc = data.pop_front() % (
			[base_percent_basic_bolt]
	)
	
	skill_tree.BasicAtk_array[1].skill_name = data.pop_front()
	skill_tree.BasicAtk_array[1].skill_desc = data.pop_front() % (
			[scale_stat]
	)
	
	skill_tree.BasicAtk_array[2].skill_name = data.pop_front()
	skill_tree.BasicAtk_array[2].skill_desc = data.pop_front() % (
			[base_percent_lightning_bolt, scale_percent_lightning_bolt]
	)
	
	skill_tree.BasicAtk_array[3].skill_name = data.pop_front()
	skill_tree.BasicAtk_array[3].skill_desc = data.pop_front() 
	
	# char's ult nodes
	skill_tree.Ult_array[0].skill_name = data.pop_front()
	skill_tree.Ult_array[0].skill_desc = data.pop_front() % (
			[base_ult_percent_tier1, base_charge_rate]
	)
	
	skill_tree.Ult_array[1].skill_name = data.pop_front()
	skill_tree.Ult_array[1].skill_desc = data.pop_front() % (
			[base_ult_percent_tier2, scale_ult_percent_tier1, scale_ult_percent_tier2]
	)
	
	skill_tree.Ult_array[2].skill_name = data.pop_front()
	skill_tree.Ult_array[2].skill_desc = data.pop_front() % (
			[base_percent_basic_bolt]
	)
	
	skill_tree.Ult_array[3].skill_name = data.pop_front()
	skill_tree.Ult_array[3].skill_desc = data.pop_front() % (
			[scale_charge_rate]
	)

func get_txt_info() -> Array:
	var file := FileAccess.open("res://csv_files/blue_city_character_skill_info - skill description.csv"
			, FileAccess.READ)
	var data_set: Array = Array(file.get_csv_line() )
	
	# seems kinda bad to rely on arbitrary index bounds
	# better to reformat CSV so that it knows which array to put it in
	while !file.eof_reached() and data_set[0] != "Knight":
		data_set = Array(file.get_csv_line() ) # travels to next csv line
	
	#print(data_set)
	file.close()
	return data_set

func compute(base: float, scaling: float, lvl: int) -> float:
	var raw_output: float = character.atk * (base + scaling * max(0, lvl - 1))
	
	return raw_output/100.0
	
