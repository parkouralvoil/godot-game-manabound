extends Node

const mana_orb_scene: PackedScene = preload("res://scenes/collectibles/mana_orb.tscn")

## so any node can access player's pos
var player_position: Vector2 = Vector2.ZERO

## for mana orb
signal call_attract_orbs
var v: int = 10

func spawn_orbs(pos: Vector2, small: int, med: int) -> void:
	var orb: ManaOrb
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
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
		@warning_ignore("integer_division")
		orb.global_position = pos + Vector2(rng.randi_range(-v/2, v/2),
			rng.randi_range(-v, v)
		)
		get_tree().root.call_deferred("add_child", orb)
