extends Node2D
class_name Knight_AbilityManager

# Character stores ammo, hp, max charge, current charge, charge rate
# AM stores projectile stats and properties

@onready var character: Character = owner
@onready var skill_tree: SkillTree = $SkillTree
@onready var Ammo: Knight_AmmoComponent = $Ammo

var data: AM_resource = preload("res://characters/knight/knight_AM_data.tres")

# vars w/o ult are basic atk
var bullet_speed: float = 400
var damage_basic_bolt: float = 5
var damage_lightning_bolt: float
var max_distance: float = 300

var ult_bullet_speed: float = 600
var ult_damage_tier1: float = 20
var ult_damage_tier2: float
var ult_max_distance: float = 1000

# base vars for stuff that scale
var base_damage_lightning_bolt: float = 8
var base_ult_damage_tier2: float = 20

var base_charge_rate: float = 75

# scaling vars
var scale_damage_lightning_bolt: float = 3
var scale_ult_damage_tier2: float = 10

var scaling_charge_rate: float = 25

# variables to make skill tree easier to track:
var level_basicAtk_ammo: int = 0:
	set(lvl):
		level_basicAtk_ammo = lvl
		character.max_ammo = 9 + (2 * lvl)
		
var level_ult_tier2: int = 0:
	set(lvl):
		level_ult_tier2 = lvl
		character.max_charge = 50 + (50 * min(lvl, 1))
		ult_damage_tier2 = base_ult_damage_tier2 + (
			scale_ult_damage_tier2 * lvl - 1)

var level_ult_chargeRate: int = 0:
	set(lvl):
		level_ult_chargeRate = lvl
		character.charge_rate = base_charge_rate + (
			scaling_charge_rate * lvl)

var level_basicAtk_burst: int = 0:
	set(lvl):
		level_basicAtk_burst = lvl
		damage_lightning_bolt = base_damage_lightning_bolt + (
			scale_damage_lightning_bolt * lvl - 1)

var skill_ult_missile: bool = false
var skill_basicAtk_double: bool = false


func skill_tree_update() -> void:
	level_basicAtk_ammo = skill_tree.BasicAtk_array[1].level
	level_ult_tier2 = skill_tree.Ult_array[1].level
	level_ult_chargeRate = skill_tree.Ult_array[3].level
	level_basicAtk_burst = skill_tree.BasicAtk_array[2].level
	
	# boolean from int, 0 = false, 1 = true
	skill_ult_missile = skill_tree.Ult_array[2].level
	skill_basicAtk_double = skill_tree.BasicAtk_array[3].level

func _ready() -> void:
	var data := get_txt_info()
	
	skill_tree.root_node.skill_name = data[1]
	skill_tree.root_node.skill_desc = data[1 + 1]
	
	var j: int = 0
	print(skill_tree.BasicAtk_array, skill_tree.Ult_array)
	for i in range(3, 9+1, 2):
		skill_tree.BasicAtk_array[j].skill_name = data[i].replace(" \n", "\n")
		skill_tree.BasicAtk_array[j].skill_desc = data[i + 1].replace(" \n", "\n")
		j += 1
	
	j = 0
	for i in range(11, 17+1, 2):
		skill_tree.Ult_array[j].skill_name = data[i].replace(" \n", "\n")
		skill_tree.Ult_array[j].skill_desc = data[i + 1].replace(" \n", "\n")
		j += 1
	#skill_tree.root_node.skill_name = "Lightning Knight"
	#skill_tree.root_node.skill_desc = (
		#"""An infantry soldier wielding a rapid-fire crossbow.\nc
#Basic atk: %d dmg
#Ult Tier 1: %d dmg\nc
#Originated from the City of Light, these lightning knights serve as the stewards of innovation.\nc
#Element: Lightning""".replace("\nc", "\n") % [damage_basic_bolt, ult_damage_tier1])

func get_txt_info() -> Array:
	var file = FileAccess.open("res://characters/blue_city_character_skill_info.csv", 
		FileAccess.READ)
	var data_set: Array = Array(file.get_csv_line())
	
	# seems kinda bad to rely on arbitrary index bounds
	# better to reformat CSV so that it knows which array to put it in
	while !file.eof_reached() and data_set[0] != "Knight":
		data_set = Array(file.get_csv_line()) # travels to next csv line
	
	print(data_set)
	file.close()
	return data_set
