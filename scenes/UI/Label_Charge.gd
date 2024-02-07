extends Label

@export var p: Player

var format_string: String = "Charge: %s/%s"
var actual_string: String = "aa"

func _process(delta):
	if p:
		actual_string = format_string % [snapped(p.ultimate.charge, 10), p.ultimate.max_charge]
		text = actual_string
		scale = Vector2(0.5, 0.5)
