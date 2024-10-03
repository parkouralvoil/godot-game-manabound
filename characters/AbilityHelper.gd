extends Node
class_name AbilityHelper

## NOTE: goddamn godot 4.3 changing how const works...
static var PlayerInfo: PlayerInfoResource = preload("res://resources/data/player_info/player_info.tres")

## also TODO: ability helper is accessible outside of abilit managers which is bad

static func compute_damage(base: float, scaling: float, level: int, stats: CharacterStats) -> float:
	var output: float = (stats.ATK + PlayerInfo.buff_raw_atk) * (base 
		+ scaling * max(0, level - 1))
	return output
