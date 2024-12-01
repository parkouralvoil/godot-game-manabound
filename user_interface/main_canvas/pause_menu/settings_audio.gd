extends Control

func _ready() -> void:
	_on_master_value_changed(0.5)

func _on_master_value_changed(value: float) -> void:
	set_volume(0, value)


func _on_music_value_changed(value: float) -> void:
	set_volume(1, value)


func _on_sound_value_changed(value: float) -> void:
	set_volume(2, value)


func set_volume(idx: int, value: float) -> void:
	AudioServer.set_bus_volume_db(idx, linear_to_db(value))
