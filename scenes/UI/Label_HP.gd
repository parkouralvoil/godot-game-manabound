extends Label

@export var entity: CharacterBody2D

var format_string: String = "HP: %s/%s"
var actual_string: String = "aaa"

func _process(delta):
	if entity is Player:
		actual_string = format_string % [str(PlayerInfo.displayed_health), str(PlayerInfo.displayed_max_health)]
	else:
		actual_string = format_string % [str(entity.health), str(entity.max_health)]
	text = actual_string
	scale = Vector2(0.5, 0.5)
