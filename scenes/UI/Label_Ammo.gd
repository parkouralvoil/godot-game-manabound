extends Label

@export var p: Player

var format_string: String = "Ammo: %d/%d"
var actual_string: String = "aa"

func _process(_delta: float) -> void:
	if p:
		actual_string = format_string % [PlayerInfo.displayed_ammo, PlayerInfo.displayed_max_ammo]
		text = actual_string
	
