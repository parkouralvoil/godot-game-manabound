extends TextureRect

var color_transparent: Color = Color(1, 1, 1, 0)
var color_visible: Color = Color(1, 1, 1, 1)

# for the love of god find/make a better placeholder sprite this looks so off

func _ready() -> void:
	modulate = color_transparent

func _process(_delta: float) -> void:
	pass

func display_blood() -> void: # called by player thru export
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", color_transparent, 1).from(color_visible)
