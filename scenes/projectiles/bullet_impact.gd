extends Sprite2D

var transparency: float = 1
var decay_rate: float = 10

func _process(delta):
	modulate = Color(1,1,1, transparency)
	transparency = lerp(transparency, 0.0, decay_rate * delta)

func _on_lifespan_timeout():
	queue_free()
