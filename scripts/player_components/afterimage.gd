extends Sprite2D

var blue_faded: Color = Color(0.5, 0.5, 1, 0.5)
var blue_transparent: Color = Color(0.5, 0.5, 1, 0.1)

var red_faded: Color = Color(1, 0.5, 0.5, 0.5)
var red_transparent: Color = Color(1, 0.5, 0.5, 0.1)

var green_faded: Color = Color(0.4, 1.4, 0.4, 0.5)
var green_transparent: Color = Color(0, 0.8, 0, 0.1)

func _ready():
	var tween := create_tween()
	tween.tween_property(self, "modulate", green_transparent, 0.5).from(green_faded)
	await tween.finished
	queue_free()
