extends Resource
class_name RoomPreset

## NOTE: for now, preset will also do the ff, so that enemy_holder will handle less shit
# ill eventually need to make a resource for EnemyData, containing the scene and its stats
"""
- calculate enemy spawn chances
- has the scenes to the enemies
"""
## Normal Enemies
const AutobowScene: PackedScene = preload("res://scenes/enemies/stationary_enemies/autobow/enemy_autobow.tscn")
const DronefactoryScene: PackedScene = preload("res://scenes/enemies/stationary_enemies/dronefactory_small/enemy_dronefactory.tscn")
const LasercrystalScene: PackedScene = preload("res://scenes/enemies/stationary_enemies/laser_crystal/enemy_laser_crystal.tscn")
const EnergizedorbScene: PackedScene = preload("res://scenes/enemies/stationary_enemies/energizedOrb/enemy_energized_orb.tscn")

## Elite enemies
const MachinegunScene: PackedScene = preload("res://scenes/enemies/stationary_enemies/machinegun/enemy_machinegun.tscn")

class SpawnInfo: ## TODO: replace this with EnemySpawnInfo resource
	var scene: PackedScene
	var final_probability: float = 0 ## used for spawn calculations
	var raw_chance: float ## used to compute final probability

@export var preset_name: String = "name"
@export_category("Normal Enemies")
@export var num_of_enemies: int = 1
@export_category("Chance to spawn") ## gets average then divides
@export var autobow: float = 5
@export var orb: float = 3
@export var laser: float = 3
@export var dronefactory: float = 1


@export_category("Elite Enemies")
@export var num_of_elites: int = 1
@export_category("Chance to spawn")
@export var machinegun: float = 1

@export_category("Interactables Present")
@export var HP_potion_present: bool = false
## set by DM
var min_rune_chests: int = 0
var max_rune_chests: int = 0

@export_category("Specific Room (leave blank for normal)")
@export var room: PackedScene

var normal_enemies_info: Array[SpawnInfo] = []
var elite_enemies_info: Array[SpawnInfo] = []


func sort_chances_from_highest(a: SpawnInfo, b: SpawnInfo) -> bool:
	if a.raw_chance > b.raw_chance:
		return true
	return false

func initialize_info() -> void: ## must be called by dungeon_manager
	var autobow_info: SpawnInfo = SpawnInfo.new()
	autobow_info.scene = AutobowScene
	autobow_info.raw_chance = autobow
	normal_enemies_info.append(autobow_info)
	
	var dronefactory_info: SpawnInfo = SpawnInfo.new()
	dronefactory_info.scene = DronefactoryScene
	dronefactory_info.raw_chance = dronefactory
	normal_enemies_info.append(dronefactory_info)
	
	var laser_info: SpawnInfo = SpawnInfo.new()
	laser_info.scene = LasercrystalScene
	laser_info.raw_chance = laser
	normal_enemies_info.append(laser_info)
	
	var orb_info: SpawnInfo = SpawnInfo.new()
	orb_info.scene = EnergizedorbScene
	orb_info.raw_chance = orb
	normal_enemies_info.append(orb_info)
	
	var machinegun_info: SpawnInfo = SpawnInfo.new()
	machinegun_info.scene = MachinegunScene
	machinegun_info.raw_chance = machinegun
	elite_enemies_info.append(machinegun_info)
	
	normal_enemies_info.sort_custom(sort_chances_from_highest)
	elite_enemies_info.sort_custom(sort_chances_from_highest)
	_compute_final_probability(normal_enemies_info)
	_compute_final_probability(elite_enemies_info)

func _compute_final_probability(info_array: Array[SpawnInfo]) -> void: ## calculate chance to spawn
	var total_chance: float = 0
	for info in info_array:
		total_chance += info.raw_chance
		
	for info in info_array:
		info.final_probability = info.raw_chance/total_chance
		if info.final_probability > 1:
			push_error("SpawnInfo of (%s) somehow has higher than 1 probability" % info.scene.resource_name)
