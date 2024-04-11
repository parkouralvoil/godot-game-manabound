extends Node
class_name EnemyHolder # more like enemy manager but aosrjsejroae

const AutobowScene: PackedScene = preload("res://scenes/enemies/stationary_enemies/autobow/enemy_autobow.tscn")
const MachinegunScene: PackedScene = preload("res://scenes/enemies/stationary_enemies/machinegun/enemy_machinegun.tscn")
const DronefactoryScene: PackedScene = preload("res://scenes/enemies/stationary_enemies/dronefactory_small/enemy_dronefactory.tscn")
const LasercrystalScene: PackedScene = preload("res://scenes/enemies/stationary_enemies/laser_crystal/enemy_laser_crystal.tscn")
const EnergizedorbScene: PackedScene = preload("res://scenes/enemies/stationary_enemies/energizedOrb/enemy_energized_orb.tscn")


class SpawnInfo:
	var scene: PackedScene
	var ratio: float

var markers: Array[Marker2D] = []
var rng: RandomNumberGenerator

var enemy_chance: float = 1 # now set by main node

@export_category("Enemy Ratios [any Int]")
@export var ratio_autobow: int = 4
@export var ratio_machinegun: int = 0
@export var ratio_dronefactory: int = 0
@export var ratio_lasercrystal: int = 0
@export var ratio_energizedorb: int = 0

var info_array: Array[SpawnInfo] = []
# idea, if enemy chance exceeds 1, the overflow makes the 
# lowest chance to spawn enemies more likely

func sort_ratios_from_highest(a: SpawnInfo, b: SpawnInfo) -> bool:
	if a.ratio > b.ratio:
		return true
	return false

func setup_info_array() -> void: ## BEHOLD THE MIGHT OF MANUAL LABOUR
	## ok for reals this might be better off as resources
		## but then id have "spawn resources" aka more data containers arghhh
		## i mean thats the point tho
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
	
	info_array.sort_custom(sort_ratios_from_highest)

func spawn_enemies() -> void:
	# calculate chance to spawn
	EventBus.enemy_died.connect(enemy_dead)
	setup_info_array()
	var total_chance: int = 0
	for info in info_array:
		total_chance += info.ratio
	for m in get_children():
		if not (m is Marker2D):
			continue
		markers.append(m)
	randomize()
	markers.shuffle()
	
	var max_enemies: int = max(markers.size() * enemy_chance, 1)
	var enemy_to_spawn: SpawnInfo = info_array[info_array.size() - 1]
	rng = RandomNumberGenerator.new()
	
	for i in range(max_enemies):
		info_array.shuffle()
		var offset: int = 0
		for j in range(info_array.size()):
			var random: int = rng.randi() % total_chance
			if random <= info_array[j].ratio + offset:
				enemy_to_spawn = info_array[j]
				break
			else:
				offset += info_array[j].ratio
		markers[i].add_child(
				instantiate_enemy(enemy_to_spawn))


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


func enemy_dead() -> void:
	EnemyAiManager.enemies_alive -= 1
	if EnemyAiManager.enemies_alive <= 0:
		owner.open_door()


func roll_probability(success_chance: float) -> bool:
	var probability: float = rng.randf()
	return probability <= success_chance
