extends Area2D
class_name Interactable

signal changed_show(allowed: bool)

@onready var arrow: Sprite2D = $arrow

func select_this() -> void:
	EventBus.interactable_detected.emit(self)


func _physics_process(_delta: float) -> void:
	var target_pos := EnemyAiManager.player_position
	if global_position.distance_squared_to(target_pos) <= 10000:
		hide()
	else:
		var dir := global_position.direction_to(target_pos)
		show()
		arrow.global_position = target_pos + Vector2(-75, 0).rotated(dir.angle())
		arrow.rotation = dir.angle() + deg_to_rad(-135)


func set_color(parent: Node) -> void:
	if parent is ExitDoor:
		arrow.modulate = Color(0, 1, 0)
	elif parent is DownedCharacter:
		arrow.modulate = Color(1, 0.5, 0)
	#elif parent is TreeStation:
	#	arrow.modulate = Color(0, 0, 1)
