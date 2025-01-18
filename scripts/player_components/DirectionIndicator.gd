extends Sprite2D

@export var p: Player

func _physics_process(_delta: float) -> void:
	self.rotation = (p.PlayerInfo.mouse_direction).angle() + (PI/4)
	if p.PlayerInfo.current_state == PlayerInfoResource.States.STANCE:
		if self_modulate != Color(1, 0.2, 0.2):
			self_modulate = Color(1, 0.2, 0.2)
	else:
		if self_modulate != Color(1, 1, 1):
			self_modulate = Color(1, 1, 1)
