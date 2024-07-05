extends Label

@export var p: Player

var format_string: String = "Ammo: %d/%d"
var actual_string: String = "aa"

func _process(_delta: float) -> void:
	if p:
		actual_string = format_string % [p.PlayerInfo.displayed_ammo, 
			p.PlayerInfo.displayed_MAX_AMMO]
		text = actual_string
	
