extends Node2D
class_name EnemyHolder


var markers: Array[Marker2D] = []

## Variables given by Level manager
var num_of_enemies: int = 0
var hp_scaling: float = 1


#@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	for m in get_children():
		if m is Marker2D:
			markers.append(m)
	markers.shuffle()


func spawn_enemies(info_array: Array[RoomPreset.SpawnInfo]) -> void: ## called by LevelManager
	var possible_max_enemies: int = min(num_of_enemies, markers.size())
	if info_array.size() <= 0: ## this means NO ENEMIES PRESENT (usually no elites for calm)
		return
	
	for i in range(possible_max_enemies):
		var chosen_info: RoomPreset.SpawnInfo
		var pity: float = 0 ## necessary to ensure an enemy is guaranteed to be selected
		for info in info_array:
			if RNG.roll_probability(info.final_probability + pity): ## with this method, its POSSIBLE not to roll anything
				chosen_info = info
				break
			pity += info.final_probability
		if not chosen_info: ## backup check
			printerr("(%s) a null info was passed" % name)
		else:
			markers[i].add_child(_instantiate_enemy(chosen_info))


func _instantiate_enemy(info: RoomPreset.SpawnInfo) -> BaseEnemy:
	var inst: BaseEnemy = info.scene.instantiate()
	inst.HP_multiplier *= hp_scaling
	return inst

## idea, have the data manager already affect the enemy's HP scaling before
## enemy_holder gets a hold of it
## orajseurasjeuorjaosejroasjeorsur ORAOEUARJOWEHROWUER

#func roll_probability(success_chance: float) -> bool:
	#var probability: float = rng.randf()
	#return probability <= success_chance ## true if probability is <= success
