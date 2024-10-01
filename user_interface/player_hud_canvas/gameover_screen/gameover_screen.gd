extends Control
class_name GameOver

# Called when the node enters the scene tree for the first time.
func show_gameover() -> void:
	modulate = Color(1,1,1,0)
	show()
	var t := create_tween()
	t.tween_property(self, "modulate", Color(1, 1, 1, 1), 1)
	await t.finished
	get_tree().paused = true


func _on_return_pressed() -> void:
	EventBus.returned_to_mainhub.emit()
	var t := create_tween()
	t.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.9)
	await t.finished
	get_tree().paused = false
	hide()
