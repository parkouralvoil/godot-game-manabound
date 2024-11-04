extends CharacterBody2D


func _physics_process(delta: float) -> void:
	# Add the gravity.
	velocity.x = 0.001 * delta
	velocity.y = -40

	move_and_slide()
	get_parent().global_position = global_position
