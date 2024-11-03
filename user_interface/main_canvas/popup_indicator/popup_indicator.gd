extends Control
class_name PopupIndicator

@onready var label_lvlcleared: Label = %LevelCleared

func _ready() -> void:
	hide()
	EventBus.level_cleared.connect(_on_level_cleared)
	EventBus.exit_door_interacted.connect(_exit_door_interacted)

func _on_level_cleared(msg: String) -> void:
	label_lvlcleared.text = msg
	show()
	modulate = Color(1, 1, 1, 1)
	await get_tree().create_timer(2).timeout
	var tw: Tween = create_tween()
	tw.tween_property(self, "modulate", Color(0, 0, 0, 0), 1)
	await tw.finished
	hide()


func _exit_door_interacted() -> void:
	hide() ## to insta hide incase player goes thru door super early
