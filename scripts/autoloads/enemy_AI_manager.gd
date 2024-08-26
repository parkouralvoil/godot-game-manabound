extends Node

const mana_orb_scene: PackedScene = preload("res://scenes/collectibles/mana_orb.tscn")

## so any node can access player's pos
var player_position: Vector2 = Vector2.ZERO

## for mana orb
signal call_attract_orbs
var v: int = 10

func spawn_orbs(pos: Vector2, mana_orbs: float) -> void:
	var orb: ManaOrb
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	
	while mana_orbs >= 20:
		mana_orbs -= 20 ## value of med orbs
		orb = mana_orb_scene.instantiate()
		orb.tier = orb.possible_tiers.MEDIUM
		@warning_ignore("integer_division")
		orb.global_position = pos + Vector2(rng.randi_range(-v/2, v/2),
			rng.randi_range(-v, v)
		)
		get_tree().root.call_deferred("add_child", orb)
	
	while mana_orbs > 0:
		mana_orbs -= 5
		orb = mana_orb_scene.instantiate()
		orb.tier = orb.possible_tiers.SMALL
		orb.global_position = pos + Vector2(rng.randi_range(-v, v),
			rng.randi_range(-v, v)
		)
		get_tree().root.call_deferred("add_child", orb)
