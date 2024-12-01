extends Control

@onready var slider_master: HSlider = $master2
@onready var slider_music: HSlider = $music2
@onready var slider_sound: HSlider = $sound2

func _ready() -> void:
	var audio_settings := ConfigFileHandler.load_audio_settings()
	slider_master.value = audio_settings.master_volume
	slider_music.value = audio_settings.music_volume
	slider_sound.value = audio_settings.sound_volume

func _on_master_value_changed(value: float) -> void:
	set_volume(0, value)
	ConfigFileHandler.save_audio_settings("master_volume", value)


func _on_music_value_changed(value: float) -> void:
	set_volume(1, value)
	ConfigFileHandler.save_audio_settings("music_volume", value)


func _on_sound_value_changed(value: float) -> void:
	set_volume(2, value)
	ConfigFileHandler.save_audio_settings("sound_volume", value)


func set_volume(idx: int, value: float) -> void:
	AudioServer.set_bus_volume_db(idx, linear_to_db(value))
