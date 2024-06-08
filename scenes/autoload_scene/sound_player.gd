extends Node2D
class_name SoundPlayerClass

@onready var non_pos_q: Node = $NonPositionalQueue
@onready var orb_sfx_cooldown: Timer = $orb_sfx_cooldown
var non_pos_size: int = 0

var index: int = 0

func _ready() -> void:
	non_pos_size = non_pos_q.get_children().size()

func get_non_pos_sound(i: int) -> AudioStreamPlayer:
	return non_pos_q.get_child(i)

func trigger(sound: AudioStream, volume_change: float, pitch: float) -> void:
	var audio_node: AudioStreamPlayer = get_non_pos_sound(index)
	audio_node.stream = sound
	audio_node.volume_db = volume_change # 0 means default volume
	audio_node.pitch_scale = pitch
	audio_node.play(0)
	index = (index + 1) % non_pos_size

func play_sound(sound: AudioStream, volume_change: float = 0, pitch: float = 1) -> void:
	trigger(sound, volume_change, pitch)

func collected_mana_cooldown() -> bool:
	if orb_sfx_cooldown.is_stopped():
		orb_sfx_cooldown.start()
		return true
	else:
		return false
