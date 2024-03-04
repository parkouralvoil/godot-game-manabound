extends AnimationPlayer

func _ready() -> void:
	play("fade_in")
	EventBus.scene_transition.connect(go_next_lvl)


func go_next_lvl(next_scene: String) -> void:
	play("fade_out")
	await animation_finished
	get_tree().change_scene_to_file(next_scene)
