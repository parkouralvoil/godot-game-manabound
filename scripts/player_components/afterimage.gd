extends Sprite2D

var blue_faded: Color = Color(0.5, 0.5, 1, 0.5)
var blue_transparent: Color = Color(0.5, 0.5, 1, 0.1)

var red_faded: Color = Color(1, 0.5, 0.5, 0.5)
var red_transparent: Color = Color(1, 0.5, 0.5, 0.1)

var green_faded: Color = Color(0.4, 1.4, 0.4, 0.5)
var green_transparent: Color = Color(0, 0.8, 0, 0.1)

var gray_faded: Color = Color(0.8, 0.8, 0.8, 0.4)
var gray_transparent: Color = Color(0.4, 0.4, 0.4, 0.1)

func _ready() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate", gray_transparent, 0.5).from(gray_faded)
	await tween.finished
	queue_free()
