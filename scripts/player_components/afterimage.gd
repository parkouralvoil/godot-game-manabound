extends Sprite2D
class_name AfterImage

var blue_faded: Color = Color(0.5, 0.5, 1, 0.5)
var blue_transparent: Color = Color(0.5, 0.5, 1, 0.1)

var red_faded: Color = Color(1, 0.5, 0.5, 0.5)
var red_transparent: Color = Color(1, 0.5, 0.5, 0.1)

var green_faded: Color = Color(0, 1, 0.8, 0.5)
var green_transparent: Color = Color(0, 0.4, 0, 0.1)

var gray_faded: Color = Color(0.8, 0.8, 0.8, 0.4)
var gray_transparent: Color = Color(0.4, 0.4, 0.4, 0.1)

var white_faded: Color = Color(1.3, 1.3, 1.3, 0.4)
var white_transparent: Color = Color(0.4, 0.4, 0.4, 0.1)

var scolor: Color = gray_faded
var ecolor: Color = gray_transparent

func _ready() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate", ecolor, 1).from(scolor)
	await tween.finished
	queue_free()
