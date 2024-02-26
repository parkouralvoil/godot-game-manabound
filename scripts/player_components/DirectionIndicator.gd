extends Sprite2D

@export var p: Player
@onready var circle: Sprite2D = $circle

func _physics_process(_delta: float) -> void:
	self.rotation = (get_global_mouse_position() - p.global_position).angle() + (PI/4)
	if PlayerInfo.current_state == PlayerInfo.States.STANCE:
		if self_modulate != Color(1, 0.2, 0.2):
			self_modulate = Color(1, 0.2, 0.2)
	else:
		if self_modulate != Color(1, 1, 1):
			self_modulate = Color(1, 1, 1)
