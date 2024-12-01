extends Node2D

const main_scene: PackedScene = preload("res://scenes/main/main.tscn")

var pressed: bool = false

@onready var black_screen: ColorRect = $Control/black_screen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SoundPlayer.play_music(SoundPlayer.music_base)
	black_screen.hide()

func _unhandled_key_input(_event: InputEvent) -> void:
	if not pressed:
		pressed = true
		switch_to_game()


func switch_to_game() -> void:
	var t := create_tween()
	black_screen.show()
	t.tween_property(black_screen, "modulate", Color(0,0,0,1), 1).from(Color(0,0,0,0))
	await t.finished
	get_tree().change_scene_to_packed(main_scene)
