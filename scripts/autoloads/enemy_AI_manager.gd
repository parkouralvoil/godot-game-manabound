extends Node

const mana_orb_scene: PackedScene = preload("res://scenes/collectibles/mana_orb.tscn")

## so any node can access player's pos
var player_position: Vector2 = Vector2.ZERO


var enemies_alive: int

## for mana orb
@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()
signal call_attract_orbs
var v: int = 10

var small_drones: int = 0
var max_drones: int = 20

func spawn_orbs(pos: Vector2, small: int, med: int) -> void:
	var orb: ManaOrb
	for i in range(small):
		orb = mana_orb_scene.instantiate()
		orb.tier = orb.possible_tiers.SMALL
		orb.global_position = pos + Vector2(rng.randi_range(-v, v),
			rng.randi_range(-v, v)
		)
		get_tree().root.call_deferred("add_child", orb)
	
	for i in range(med):
		orb = mana_orb_scene.instantiate()
		orb.tier = orb.possible_tiers.MEDIUM
		orb.global_position = pos + Vector2(rng.randi_range(-v/2, v/2),
			rng.randi_range(-v, v)
		)
		get_tree().root.call_deferred("add_child", orb)
