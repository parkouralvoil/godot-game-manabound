extends GPUParticles2D

@onready var p: Player = owner
@onready var process_mat: ParticleProcessMaterial = process_material

func emit_boost_particles(boost_dir: Vector2) -> void:
	process_mat.direction = Vector3(-boost_dir.x, -boost_dir.y, 0)
	process_mat.angle_min = Vector2.RIGHT.angle_to(boost_dir) + deg_to_rad(45)
	self.restart()
