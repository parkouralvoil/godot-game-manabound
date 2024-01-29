extends Label

@export var p: Player

var format_string: String = "Auto aim: %s"
var actual_string: String = "aa"

func _process(delta):
	if p:
		actual_string = format_string % [p.auto_aim]
		text = actual_string
		scale = Vector2(0.5, 0.5)
