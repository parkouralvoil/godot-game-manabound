extends ColorRect

@export var area_tutorial_data: AreaTutorialData

func _ready() -> void:
	if not area_tutorial_data.completed:
		show()
		EventBus.mainhub_departed.connect(_hide_screen.unbind(1))
	else:
		hide()

func _hide_screen() -> void:
	await get_tree().create_timer(0.5).timeout
	hide()
