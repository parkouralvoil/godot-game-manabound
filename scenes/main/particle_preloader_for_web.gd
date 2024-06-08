extends Node2D

@export var par_array: Array[ParticleProcessMaterial] = []

func _ready() -> void:
	for p in par_array:
		ParticlesQueueNode.set_property_restart(
			p,
			null,
			true,
			2,
			1,
			1,
			Vector2.ZERO
		)
