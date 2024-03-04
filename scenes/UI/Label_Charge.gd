extends Label

@export var p: Player

var format_string: String = "Charge: %d/%d"
var actual_string: String = "aa"

func _process(_delta: float) -> void:
	if !p:
		return
	
	actual_string = format_string % [snapped(PlayerInfo.displayed_charge, 1), PlayerInfo.displayed_max_charge]
	text = actual_string
	if PlayerInfo.displayed_charge >= 100:
		modulate = Color(1, 0.2, 0.2)
	elif PlayerInfo.displayed_charge >= 50:
		modulate = Color(1, 1, 0.2)
	elif PlayerInfo.displayed_charge >= 1:
		modulate = Color(1, 1, 1, 0.8)
	else:
		modulate = Color(0.6, 0.6, 0.6, 0.8)
