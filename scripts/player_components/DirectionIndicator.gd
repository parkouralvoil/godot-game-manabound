extends Sprite2D

@export var p: Player

func _physics_process(delta):
	self.rotation = (p.global_position - get_global_mouse_position()).angle() - (PI/4 + PI/2)
