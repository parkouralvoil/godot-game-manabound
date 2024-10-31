extends Label
class_name LabelCombatText

var speed: int = -40
var duration: float = 0.6

func _ready() -> void:
	await get_tree().create_timer(duration).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position += Vector2(0, speed * delta)
