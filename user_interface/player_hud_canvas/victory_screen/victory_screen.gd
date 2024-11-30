extends Control
class_name VictoryScreen

@export var victory_sfx: AudioStream

var _already_pressed: bool = false

@onready var label_reason: Label = %reason
@onready var label_progress: Label = %progress
@onready var label_orbs: Label = %orbs
@onready var label_enemies: Label = %enemies
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	EventBus.expedition_completed.connect(_show_victory)


func _show_victory(message: String) -> void: ## called by EventBus
	_already_pressed = false
	label_reason.text = message
	label_progress.text = "Rooms explored: %d" % LevelSumamry.rooms_entered
	label_orbs.text = "Orbs collected: %d" % LevelSumamry.orbs_collected
	label_enemies.text = "Enemies defeated: %d" % LevelSumamry.enemies_killed
	modulate = Color(1,1,1,0)
	show()
	var t := create_tween()
	t.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.5)
	await t.finished
	SoundPlayer.play_notification_sound(victory_sfx, -12)
	get_tree().paused = true


func _on_return_pressed() -> void:
	if _already_pressed:
		return
	_already_pressed = true
	EventBus.returned_to_mainhub.emit()
	var t := create_tween()
	t.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.9)
	await t.finished
	get_tree().paused = false
	hide()
