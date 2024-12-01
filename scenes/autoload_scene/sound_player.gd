extends Node2D
class_name SoundPlayerClass

@export_category("Musics")
@export var music_base: AudioStream
@export var music_tutorial: AudioStream
@export var music_aumaLuineCombat: AudioStream
@export var music_aumaLuineRest: AudioStream
@export var music_railgun: AudioStream

@export_category("Sword impacts")
@export var sword_hits: Array[AudioStream]

var short_pos_size: int = 0
var pos_size: int = 0
var non_pos_size: int = 0

var short_pos_index: int = 0
var pos_index: int = 0
var non_pos_index: int = 0

var _current_music: AudioStream = null

@onready var short_pos_q: Node2D = $ShortPositionalQueue ## INTENDED FOR FAST SFX (enemy explosion)
@onready var pos_q: Node2D= $PositionalQueue             ## INTENDED FOR LONG SFX (frost nova)
@onready var non_pos_q: Node = $NonPositionalQueue       ## MOST USED
@onready var orb_sfx_cooldown: Timer = $orb_sfx_cooldown
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var notification_player: AudioStreamPlayer = $NotificationPlayer

func _ready() -> void:
	short_pos_size = short_pos_q.get_children().size()
	pos_size = pos_q.get_children().size()
	non_pos_size = non_pos_q.get_children().size()


#region Positional-sounds
func _trigger_short_pos(pos: Vector2, sound: AudioStream, volume_change: float, pitch: float) -> void:
	var audio_node: AudioStreamPlayer2D = short_pos_q.get_child(short_pos_index)
	audio_node.position = pos
	audio_node.stream = sound
	audio_node.volume_db = volume_change # 0 means default volume
	audio_node.pitch_scale = pitch
	audio_node.play(0)
	short_pos_index = (short_pos_index + 1) % short_pos_size


func _trigger_pos(pos: Vector2, sound: AudioStream, volume_change: float, pitch: float) -> void:
	var audio_node: AudioStreamPlayer2D = pos_q.get_child(pos_index)
	audio_node.position = pos
	audio_node.stream = sound
	audio_node.volume_db = volume_change # 0 means default volume
	audio_node.pitch_scale = pitch
	audio_node.play(0)
	pos_index = (pos_index + 1) % pos_size

func play_sound_2D(pos: Vector2, sound: AudioStream, volume_change: float = 0, pitch: float = 1) -> void:
	if sound.get_length() > 4: # longer than 2 seconds
		_trigger_pos(pos, sound, volume_change, pitch)
	else:
		_trigger_short_pos(pos, sound, volume_change, pitch)
#endregion

#region Non-positional-sounds
func _trigger(sound: AudioStream, volume_change: float, pitch: float) -> void:
	var audio_node: AudioStreamPlayer = non_pos_q.get_child(non_pos_index)
	audio_node.stream = sound
	audio_node.volume_db = volume_change # 0 means default volume
	audio_node.pitch_scale = pitch
	audio_node.play(0)
	non_pos_index = (non_pos_index + 1) % non_pos_size

func play_sound(sound: AudioStream, volume_change: float = 0, pitch: float = 1) -> void:
	_trigger(sound, volume_change, pitch)
#endregion

func collected_mana_cooldown() -> bool:
	if orb_sfx_cooldown.is_stopped():
		orb_sfx_cooldown.start()
		return true
	else:
		return false

## Music functions
func play_music(music: AudioStream) -> void:
	if music:
		if not _current_music:
			_current_music = music
			music_player.stream = music
			music_player.play()
		elif _current_music == music:
			pass ## ( no need to do anything )
		else:
			stop_music()
			_current_music = music
			music_player.stream = music
			music_player.play()
	#print_debug("called this")

func stop_music() -> void:
	_current_music = null
	music_player.stop()

func lower_volume() -> void:
	music_player.volume_db = -28

func normal_volume() -> void:
	music_player.volume_db = -20

## notification sound, like music it runs even if game is paused
func play_notification_sound(sound: AudioStream, vol: float) -> void:
	notification_player.stream = sound
	notification_player.volume_db = vol
	notification_player.play()

## doing this here incase the sword swing is queue'd freed or smthg
func play_sword_impact_sound() -> void:
	var chosen_impact: AudioStream = sword_hits.pick_random()
	play_sound(chosen_impact, -17, 1.1)
