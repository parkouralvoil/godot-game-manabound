extends Sprite2D
class_name BulletImpact

# BulletImpact VS DamageImpact
	# bul impact: it only serves as decor (sprite 2d and timer)
	# dmg Impact: it deals dmg/procs elems (has area2d node)

var transparency: float = 1
var decay_rate: float = 10

func _process(delta: float) -> void:
	modulate = Color(1,1,1, transparency)
	transparency = lerp(transparency, 0.0, decay_rate * delta)

func _on_lifespan_timeout() -> void:
	queue_free()
