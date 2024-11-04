extends Node

const mana_orb_scene: PackedScene = preload("res://scenes/collectibles/mana_orb.tscn")

## number of enemies present:
var enemies_alive: int = 0:
	set(val):
		enemies_alive = max(val, 0)
var small_drones: int = 0:
	set(val):
		small_drones = max(val, 0)
var max_drones: int = 20

## so any node can access player's pos
var player_position: Vector2 = Vector2.ZERO

## for mana orb
signal call_attract_orbs
var v: int = 10


func reset_enemies() -> void: ## called everytime a new level is entered
	enemies_alive = 0
	small_drones = 0


## shouldnt be in ENemyAIManager but whatever
func spawn_orbs(pos: Vector2, mana_orbs: float) -> void:
	var orb: ManaOrb
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	
	while mana_orbs >= ManaOrb.value_med:
		mana_orbs -= ManaOrb.value_med ## value of med orbs
		orb = mana_orb_scene.instantiate()
		orb.tier = orb.possible_tiers.MEDIUM
		@warning_ignore("integer_division")
		orb.global_position = pos + Vector2(rng.randi_range(-v/2, v/2),
			rng.randi_range(-v, v)
		)
		get_tree().root.call_deferred("add_child", orb)
	
	while mana_orbs > 0:
		mana_orbs -= ManaOrb.value_small
		orb = mana_orb_scene.instantiate()
		orb.tier = orb.possible_tiers.SMALL
		orb.global_position = pos + Vector2(rng.randi_range(-v, v),
			rng.randi_range(-v, v)
		)
		get_tree().root.call_deferred("add_child", orb)
