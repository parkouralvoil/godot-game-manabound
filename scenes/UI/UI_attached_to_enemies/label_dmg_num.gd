extends Label

func _ready() -> void:
	await get_tree().create_timer(0.6).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position += Vector2(0, -40 * delta)
