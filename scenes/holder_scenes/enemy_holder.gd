extends Node
class_name EnemyHolder # more like enemy manager but aosrjsejroae

const AutobowScene: PackedScene = preload("res://scenes/enemies/stationary_enemies/autobow/enemy_autobow.tscn")
const MachinegunScene: PackedScene = preload("res://scenes/enemies/stationary_enemies/machinegun/enemy_machinegun.tscn")
const DronefactoryScene: PackedScene = preload("res://scenes/enemies/stationary_enemies/dronefactory_small/enemy_dronefactory.tscn")
const LasercrystalScene: PackedScene = preload("res://scenes/enemies/stationary_enemies/laser_crystal/enemy_laser_crystal.tscn")
const EnergizedorbScene: PackedScene = preload("res://scenes/enemies/stationary_enemies/energizedOrb/enemy_energized_orb.tscn")

@export var tool_button_spawn: bool = false :
	set(val):
		spawn_enemies()

@export var tool_button_clear: bool = false :
	set(val):
		remove_enemies()

class SpawnInfo:
	var scene: PackedScene
	var starting_interval: int
	var ratio: int

var markers: Array[Marker2D] = []
var rng: RandomNumberGenerator

var enemy_chance: float = 0 # now set by main node

@export_category("Enemy Ratios, ex: 30% is 30")
@export var ratio_autobow: int = 30
@export var ratio_machinegun: int = 10
@export var ratio_dronefactory: int = 10
@export var ratio_lasercrystal: int = 20
@export var ratio_energizedorb: int = 30

var info_array: Array[SpawnInfo] = []
# idea, if enemy chance exceeds 1, the overflow makes the 
# lowest chance to spawn enemies more likely

func sort_ratios_from_lowest(a: SpawnInfo, b: SpawnInfo) -> bool:
	if a.ratio < b.ratio:
		return true
	return false


func setup_info_array() -> void:
	var autobow: SpawnInfo = SpawnInfo.new()
	autobow.scene = AutobowScene
	autobow.ratio = ratio_autobow
	info_array.append(autobow)
	
	var machinegun: SpawnInfo = SpawnInfo.new()
	machinegun.scene = MachinegunScene
	machinegun.ratio = ratio_machinegun
	info_array.append(machinegun)
	
	var dronefactory: SpawnInfo = SpawnInfo.new()
	dronefactory.scene = DronefactoryScene
	dronefactory.ratio = ratio_dronefactory
	info_array.append(dronefactory)
	
	var lasercrystal: SpawnInfo = SpawnInfo.new()
	lasercrystal.scene = LasercrystalScene
	lasercrystal.ratio = ratio_lasercrystal
	info_array.append(lasercrystal)
	
	var energizedorb: SpawnInfo = SpawnInfo.new()
	energizedorb.scene = EnergizedorbScene
	energizedorb.ratio = ratio_energizedorb
	info_array.append(energizedorb)
	
	info_array.sort_custom(sort_ratios_from_lowest)

func spawn_enemies() -> void: ## calculate chance to spawn
	if not Engine.is_editor_hint():
		EventBus.enemy_died.connect(enemy_dead)
	setup_info_array()
	var total_chance: int = 0
	for info in info_array:
		info.starting_interval = total_chance
		total_chance += info.ratio
	for m in get_children():
		if not (m is Marker2D):
			continue
		markers.append(m)
	randomize()
	markers.shuffle()
	
	var max_enemies: int = max(markers.size() * enemy_chance, 1)
	var chosen_info: SpawnInfo = info_array[info_array.size() - 1]
	rng = RandomNumberGenerator.new()
	
	for i in range(max_enemies):
		#info_array.shuffle()
		var offset: float = 0
		var random: int = rng.randi() % 100
		## it works like this;
		## autobow: 30%		[0, 29]
		## machinegun: 10%	[30, 39]
		## dronefac: 10%	[40, 49]
		## laser: 20%		[50. 69]
		## energy: 30%		[70, 99]
		for info in info_array:
			var ending_interval: int = info.starting_interval + info.ratio - 1
			if info.starting_interval <= random and random <= ending_interval:
				chosen_info = info
				break
		markers[i].add_child(instantiate_enemy(chosen_info))

func remove_enemies(): ## TOOL SCRIPT
	if Engine.is_editor_hint():
		for mark in markers:
			if mark.get_child(0) is BaseEnemy:
				mark.get_child(0).queue_free()

func instantiate_enemy(info: SpawnInfo) -> BaseEnemy:
	var inst: BaseEnemy
	match info.scene:
		LasercrystalScene:
			inst = (info.scene).instantiate() as LaserEnemy
			if roll_probability(0.4):
				inst.horizontal = true
			if roll_probability(0.4):
				inst.horizontal = false
				inst.spinning = true
		_:
			inst = (info.scene).instantiate()
	#inst.dead.connect(enemy_dead) # I CANT DO THIS CUZ DRONEFACTORY SPAWNS ITS OWN ENEMIES
	return inst


func enemy_dead(type: BaseEnemy) -> void:
	EnemyAiManager.enemies_alive -= 1
	if type is Enemy_SmallDrone:
		EnemyAiManager.small_drones -= 1
	if EnemyAiManager.enemies_alive <= 0:
		var lvl: LevelManager = owner
		lvl.level_is_cleared()


func roll_probability(success_chance: float) -> bool:
	var probability: float = rng.randf()
	return probability <= success_chance
