extends Control
class_name GameOver

@export var gameover_sfx: AudioStream

var _already_pressed: bool = false

@onready var label_reason: Label = %reason
@onready var label_progress: Label = %progress
@onready var label_orbs: Label = %orbs
@onready var label_enemies: Label = %enemies
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	EventBus.return_to_base_pressed.connect(show_gameover_player_gaveup)


func show_gameover_characters_dead() -> void: ## called by PlayerHudCanvas
	label_reason.text = "All party members wiped out."
	_show_gameover()


func show_gameover_player_gaveup() -> void:
	label_reason.text = "Expedition ended prematurely."
	_show_gameover()


func _show_gameover() -> void:
	_already_pressed = false
	label_progress.text = "Rooms explored: %d" % LevelSumamry.rooms_entered
	label_orbs.text = "Orbs collected: %d" % LevelSumamry.orbs_collected
	label_enemies.text = "Enemies defeated: %d" % LevelSumamry.enemies_killed
	modulate = Color(1,1,1,0)
	show()
	var t := create_tween()
	t.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.5)
	await t.finished
	SoundPlayer.play_notification_sound(gameover_sfx, -5)
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
