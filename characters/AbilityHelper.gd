extends Node
class_name AbilityHelper


const PlayerInfo: PlayerInfoResource = preload("res://resources/data/player_info/player_info.tres")


static func compute_damage(base: float, scaling: float, level: int, stats: CharacterStats) -> float:
	var output: float = (stats.ATK + PlayerInfo.buff_raw_atk) * (base 
		+ scaling * max(0, level - 1))
	
	return output
