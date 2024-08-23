extends TextureRect
class_name BloodOverlay


func initialize(new_player_info: PlayerInfoResource) -> void:
	new_player_info.player_got_hit.connect(trigger_blood_overlay)


func trigger_blood_overlay() -> void:
	var color_transparent: Color = Color(1, 1, 1, 0)
	var color_visible: Color = Color(1, 1, 1, 1)
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", color_transparent, 1).from(color_visible)
