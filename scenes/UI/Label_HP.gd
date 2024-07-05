extends Label

@export var p: Player

var format_string: String = "HP: %s/%s"
var actual_string: String = "aaa"

func _process(_delta: float) -> void:
	if p:
		actual_string = format_string % [str(p.PlayerInfo.displayed_HP), 
			str(p.PlayerInfo.displayed_MAX_HP)]
	text = actual_string
