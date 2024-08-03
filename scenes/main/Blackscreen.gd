extends ColorRect


func fade_in() -> void:
	var t: Tween = create_tween()
	t.tween_property(self, "color", Color(0,0,0,1), 0.5)


func fade_out() -> void:
	var t: Tween = create_tween()
	t.tween_property(self, "color", Color(0,0,0,0), 0.5)
