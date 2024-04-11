extends Node2D


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("r"):
		get_tree().reload_current_scene()
