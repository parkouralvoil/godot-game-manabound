extends Camera2D

var dir: Vector2
var spd: float = 1

func _process(_delta: float) -> void:
	if Input.is_action_pressed("right"):
		dir = Vector2.RIGHT
	elif Input.is_action_pressed("left"):
		dir = Vector2.LEFT
	elif Input.is_action_pressed("up"):
		dir = Vector2.UP
	elif Input.is_action_pressed("down"):
		dir = Vector2.DOWN
	else:
		dir = Vector2.ZERO
	
	position += spd * dir
