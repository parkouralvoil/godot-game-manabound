extends Node2D
class_name ParticleQueue

var queue_count: int = 40

var index: int = 0

func _ready() -> void:
	queue_count = get_children().size()
	pass
	#for i in range(queue_count):
		#add_child(particle_scene.instantiate() )


func _get_next_particle() -> GPUParticles2D:
	return get_child(index)


func _trigger() -> void:
	_get_next_particle().restart()
	index = (index + 1) % queue_count


func set_property_restart(process_mat: ParticleProcessMaterial,
		texture: Texture,
		one_shot: bool,
		amt: int,
		explosiveness: float,
		lifetime: float,
		pos: Vector2,
		direction: Vector2 = Vector2.ZERO) -> void:
	var p: GPUParticles2D = _get_next_particle()
	if direction != Vector2.ZERO:
		process_mat.direction = Vector3(direction.x, direction.y, 0)
	p.process_material = process_mat
	p.texture = texture
	p.one_shot = one_shot
	p.amount = amt
	p.explosiveness = explosiveness
	p.lifetime = lifetime
	p.global_position = pos
	_trigger()
