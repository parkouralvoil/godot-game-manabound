extends Node

const SETTINGS_FILE_PATH := "user://settings.ini"
const AREA_DATA_FILE_PATH := "user://area_data.ini"

var area_blueCity: AreaData = preload("res://resources/data/dungeon_managers/blueCity/areas/area_city.tres")
var area_tutorial: AreaData = preload("res://resources/data/dungeon_managers/novicePlains/area/area_tutorial.tres")

var config_settings: ConfigFile = ConfigFile.new()
var config_areas: ConfigFile = ConfigFile.new()
## settings sections
const video: String = "video"
const audio: String = "audio"
const other: String = "other"

## area sections
const CompletedAreas: String = "completed"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initialize_settings()
	_initialize_area_data()

## CALL INITIALIZE FUNCTIONS ON READY:
func _initialize_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_FILE_PATH):
		config_settings.set_value(other, "camera_shake", Settings.camera_shake)
		config_settings.set_value(other, "invert_mouse_distance", Settings.inverted_hover)
		config_settings.set_value(other, "show_fps", Settings.show_fps)
		
		config_settings.set_value(video, "fullscreen", false)
		config_settings.set_value(video, "vsync_index", 1)
		
		config_settings.set_value(audio, "master_volume", 0.5)
		config_settings.set_value(audio, "music_volume", 1)
		config_settings.set_value(audio, "sound_volume", 1)
		
		config_settings.save(SETTINGS_FILE_PATH)
	else:
		config_settings.load(SETTINGS_FILE_PATH)
		## on startup, set music volume here
		var audio_settings := load_audio_settings()
		var master_vol: float = audio_settings.master_volume
		var music_vol: float = audio_settings.music_volume
		AudioServer.set_bus_volume_db(0, linear_to_db(master_vol))
		AudioServer.set_bus_volume_db(1, linear_to_db(music_vol))

func _initialize_area_data() -> void:
	if not FileAccess.file_exists(AREA_DATA_FILE_PATH):
		config_areas.set_value(CompletedAreas, "blue_city", false)
		config_areas.set_value(CompletedAreas, "tutorial", false)
	else:
		config_areas.load(AREA_DATA_FILE_PATH)
		
		var completed_areas := load_completed_areas()
		area_blueCity.completed = completed_areas.blue_city
		area_tutorial.completed = completed_areas.tutorial

func save_area_completed(area: String, value: bool) -> void:
	config_areas.set_value(CompletedAreas, area, value)
	config_areas.save(AREA_DATA_FILE_PATH)

func load_completed_areas() -> Dictionary:
	var area_data := {}
	for key in config_areas.get_section_keys(CompletedAreas):
		area_data[key] = config_areas.get_value(CompletedAreas, key)
	return area_data


func save_video_settings(key: String, value) -> void:
	config_settings.set_value(video, key, value)
	config_settings.save(SETTINGS_FILE_PATH)

func load_video_settings() -> Dictionary:
	var vid_settings := {}
	for key in config_settings.get_section_keys(video):
		vid_settings[key] = config_settings.get_value(video, key)
	return vid_settings

func save_audio_settings(key: String, value: float) -> void:
	config_settings.set_value(audio, key, value)
	config_settings.save(SETTINGS_FILE_PATH)

func load_audio_settings() -> Dictionary:
	var audio_settings := {}
	for key in config_settings.get_section_keys(audio):
		audio_settings[key] = config_settings.get_value(audio, key)
	return audio_settings

func save_other_settings(key: String, value: bool) -> void:
	config_settings.set_value(other, key, value)
	config_settings.save(SETTINGS_FILE_PATH)

func load_other_settings() -> Dictionary:
	var other_settings := {}
	for key in config_settings.get_section_keys(other):
		other_settings[key] = config_settings.get_value(other, key)
	return other_settings
