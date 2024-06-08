extends Label

@export var p: Player

var format_string: String = "Aim: %s"
var actual_string: String = "aa"

func _process(_delta: float) -> void:
	if p:
		if not p.auto_aim:
			actual_string = format_string % ["Manual"]
		else:
			actual_string = format_string % ["Auto"]
		text = actual_string
