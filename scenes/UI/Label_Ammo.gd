extends Label

@export var p: Player

var format_string: String = "Ammo: %s/%s"
var actual_string: String = "aa"

func _process(_delta: float) -> void:
	if p:
		actual_string = format_string % [str(PlayerInfo.displayed_ammo), str(PlayerInfo.displayed_max_ammo)]
		text = actual_string
	
