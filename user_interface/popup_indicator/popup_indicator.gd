extends Control
class_name PopupIndicator


func show_lvl_cleared() -> void:
	show()
	modulate = Color(1, 1, 1, 1)
	await get_tree().create_timer(2).timeout
	var tw: Tween = create_tween()
	tw.tween_property(self, "modulate", Color(0, 0, 0, 0), 1)
	await tw.finished
	hide()
