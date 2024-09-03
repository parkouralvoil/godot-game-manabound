extends Bullet

@export var process_mat: ParticleProcessMaterial

func _on_area_entered(hurtbox: Area2D) -> void:
	if hurtbox.has_method("hit"):
		hurtbox.hit(damage, element, ep) ## BRUH
		spawn_impact_particles()
	disappear()

func spawn_impact_particles() -> void:
	if _travelled_distance > max_distance:
		return
	var dir: Vector2 = -Vector2.RIGHT.rotated(rotation)
	process_mat.direction = Vector3(dir.x, dir.y, 0)
	ParticlesQueueNode.set_property_restart(process_mat,
		null,
		true,
		8,
		0.7,
		0.3,
		global_position)
