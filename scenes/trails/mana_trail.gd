extends Line2D
class_name Trail ## turn on TOP LEVEL!!!!!!!!!!!!

const MAX_POINTS: int = 10
@onready var curve: = Curve2D.new()

var queue: Array[Vector2] = []

func _physics_process(_delta: float) -> void:
	var pos: Vector2 = _get_position()
	
	queue.push_front(pos)
	
	if queue.size() > MAX_POINTS:
		queue.pop_back()
	
	clear_points()
	for point in queue:
		add_point(point)


func _get_position() -> Vector2:
	if get_parent():
		var source: Node2D = get_parent()
		return source.position
	return Vector2.ZERO

#
#func stop() -> void:
	#set_process(false)
	#var tw: Tween = get_tree().create_tween()
	#tw.tween_property(self, "modulate.a", 0.0, 3.0)
	#await tw.finished
	#queue_free()
