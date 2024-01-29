extends Sprite2D

@export var p: Player

func _physics_process(delta):
	self.rotation = (get_global_mouse_position() - p.global_position).angle() + (PI/4)
