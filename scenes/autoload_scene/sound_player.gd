extends Node2D
class_name SoundPlayerClass

@onready var short_pos_q: Node2D = $ShortPositionalQueue ## INTENDED FOR FAST SFX (enemy explosion)
@onready var pos_q: Node2D= $PositionalQueue             ## INTENDED FOR LONG SFX (frost nova)
@onready var non_pos_q: Node = $NonPositionalQueue       ## MOST USED
@onready var orb_sfx_cooldown: Timer = $orb_sfx_cooldown

var short_pos_size: int = 0
var pos_size: int = 0
var non_pos_size: int = 0

var short_pos_index: int = 0
var pos_index: int = 0
var non_pos_index: int = 0

func _ready() -> void:
	pos_size = pos_q.get_children().size()
	non_pos_size = non_pos_q.get_children().size()


#region Positional-sounds
func trigger_short_pos(pos: Vector2, sound: AudioStream, volume_change: float, pitch: float) -> void:
	var audio_node: AudioStreamPlayer2D = short_pos_q.get_child(short_pos_index)
	audio_node.position = pos
	audio_node.stream = sound
	audio_node.volume_db = volume_change # 0 means default volume
	audio_node.pitch_scale = pitch
	audio_node.play(0)
	pos_index = (pos_index + 1) % pos_size


func trigger_pos(pos: Vector2, sound: AudioStream, volume_change: float, pitch: float) -> void:
	var audio_node: AudioStreamPlayer2D = pos_q.get_child(pos_index)
	audio_node.position = pos
	audio_node.stream = sound
	audio_node.volume_db = volume_change # 0 means default volume
	audio_node.pitch_scale = pitch
	audio_node.play(0)
	pos_index = (pos_index + 1) % pos_size

func play_sound_2D(pos: Vector2, sound: AudioStream, volume_change: float = 0, pitch: float = 1) -> void:
	if sound.get_length() > 2: # longer than 2 seconds
		trigger_pos(pos, sound, volume_change, pitch)
	else:
		trigger_short_pos(pos, sound, volume_change, pitch)
#endregion

#region Non-positional-sounds
func trigger(sound: AudioStream, volume_change: float, pitch: float) -> void:
	var audio_node: AudioStreamPlayer = non_pos_q.get_child(non_pos_index)
	audio_node.stream = sound
	audio_node.volume_db = volume_change # 0 means default volume
	audio_node.pitch_scale = pitch
	audio_node.play(0)
	non_pos_index = (non_pos_index + 1) % non_pos_size

func play_sound(sound: AudioStream, volume_change: float = 0, pitch: float = 1) -> void:
	trigger(sound, volume_change, pitch)
#endregion

func collected_mana_cooldown() -> bool:
	if orb_sfx_cooldown.is_stopped():
		orb_sfx_cooldown.start()
		return true
	else:
		return false
