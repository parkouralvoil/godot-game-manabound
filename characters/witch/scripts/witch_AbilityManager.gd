extends Node2D
class_name Witch_AbilityManager

@onready var character: Character = owner
@onready var skill_tree: SkillTree = $SkillTree
@onready var Ammo: Witch_AmmoComponent = $Ammo

@export_category("basic atk: Base")
var bullet_speed: float = 375
var max_distance: float = 260
var base_percent_frost_spear: float = 80
var base_percent_1st_icicle: float = 30
var base_percent_2nd_icicle: float = 20

@export_category("basic atk: Scale") # ALL SCALES EVERYWHERE ARE PERCENTAGES 
var scale_percent_1st_icicle: float = 15
var scale_percent_2nd_icicle: float = 10

@export_category("ult: Base")
var base_ult_percent: float = 70
var base_ult_explosions: int = 15
var base_ult_size: float = 1

@export_category("ult: Scaling")
var scale_ult_explosions: int = 3
var scale_ult_size: float = 25 # adds to scale

@export_category("Stats")
# each char only has a specific upgrade for one stat, to ease building
var base_stat: float = 1
var scale_stat: float = 0.1 # PERCENTAGE
var base_charge_rate: float = 6 # for witch, her charge rate remains da same

var explosion_num: int = base_ult_explosions
var explosion_scale: float = base_ult_size

var frost_spike_dmg: float = 0
var first_icicle_dmg: float = 0
var second_icicle_dmg: float = 0

var frost_storm_dmg: float = 0

var level_basicAtk_firerate: int = 0:
	set(lvl):
		level_basicAtk_firerate = lvl
		Ammo.t_ammo_regen.wait_time = base_stat - (
				base_stat * scale_stat * lvl)

var level_basicAtk_second_icicle: int = 0:
	set(lvl):
		level_basicAtk_second_icicle = lvl
		first_icicle_dmg = character.atk * (base_percent_1st_icicle + 
				scale_percent_1st_icicle * lvl )/100.0
		second_icicle_dmg = character.atk * (base_percent_2nd_icicle + 
				scale_percent_2nd_icicle * lvl )/100.0

var level_ult_explosions: int = 0:
	set(lvl):
		level_ult_explosions = lvl
		explosion_num = base_ult_explosions + (
				scale_ult_explosions * lvl)

var level_ult_size: int = 0:
	set(lvl):
		level_ult_size = lvl
		explosion_scale = base_ult_size + (
				scale_ult_size/100.0 * lvl)

var skill_ult_crystalize: bool = false
var skill_basicAtk_crystalize: bool = false


func stats_update() -> void:
	frost_spike_dmg = compute(base_percent_frost_spear, 
			0,
			0,)
	first_icicle_dmg = compute(base_percent_1st_icicle, 
			scale_percent_1st_icicle,
			level_basicAtk_second_icicle,)
	second_icicle_dmg = compute(base_percent_2nd_icicle, 
			scale_percent_2nd_icicle,
			level_basicAtk_second_icicle,)
	frost_storm_dmg = compute(base_ult_percent,
			0,
			0)
	
	character.charge_rate = base_charge_rate
	level_basicAtk_firerate = skill_tree.BasicAtk_array[1].level
	level_basicAtk_second_icicle = skill_tree.BasicAtk_array[2].level
	
	level_ult_explosions = skill_tree.Ult_array[1].level
	level_ult_size = skill_tree.Ult_array[2].level
	
	# boolean from int, 0 = false, 1 = true
	skill_ult_crystalize = skill_tree.Ult_array[3].level
	skill_basicAtk_crystalize = skill_tree.BasicAtk_array[3].level

func desc_update() -> void:
	var data := get_txt_info()
	
	# description of char
	data.pop_front() # remove "witch"
	skill_tree.root_node.skill_name = data.pop_front()
	skill_tree.root_node.skill_desc = data.pop_front()
	
	# char's basic atk nodes
	skill_tree.BasicAtk_array[0].skill_name = data.pop_front()
	skill_tree.BasicAtk_array[0].skill_desc = data.pop_front() % (
			[base_percent_frost_spear, base_percent_1st_icicle]
		)
	
	skill_tree.BasicAtk_array[1].skill_name = data.pop_front()
	skill_tree.BasicAtk_array[1].skill_desc = data.pop_front() % (
			[scale_stat * 100]
	)
	
	skill_tree.BasicAtk_array[2].skill_name = data.pop_front()
	skill_tree.BasicAtk_array[2].skill_desc = data.pop_front() % (
			[base_percent_2nd_icicle, scale_percent_1st_icicle, scale_percent_2nd_icicle]
	)
	
	skill_tree.BasicAtk_array[3].skill_name = data.pop_front()
	skill_tree.BasicAtk_array[3].skill_desc = data.pop_front() 
	
	# char's ult nodes
	skill_tree.Ult_array[0].skill_name = data.pop_front()
	skill_tree.Ult_array[0].skill_desc = data.pop_front() % (
			[base_ult_percent, base_charge_rate]
	)
	
	skill_tree.Ult_array[1].skill_name = data.pop_front()
	skill_tree.Ult_array[1].skill_desc = data.pop_front() % (
			[scale_ult_explosions]
	)
	
	skill_tree.Ult_array[2].skill_name = data.pop_front()
	skill_tree.Ult_array[2].skill_desc = data.pop_front() % (
			[scale_ult_size]
	)
	
	skill_tree.Ult_array[3].skill_name = data.pop_front()
	skill_tree.Ult_array[3].skill_desc = data.pop_front()


func get_txt_info() -> Array:
	var file := FileAccess.open("res://csv_files/blue_city_character_skill_info - skill description.csv"
			, FileAccess.READ)
	var data_set: Array = Array(file.get_csv_line())
	
	# seems kinda bad to rely on arbitrary index bounds
	# better to reformat CSV so that it knows which array to put it in
	while !file.eof_reached() and data_set[0] != "Witch":
		data_set = Array(file.get_csv_line() ) # travels to next csv line
	
	#print(data_set)
	file.close()
	return data_set


func compute(base: float, scaling: float, lvl: int) -> float:
	var raw_output: float = character.atk * (base + scaling * max(0, lvl - 1))
	
	return raw_output/100.0
