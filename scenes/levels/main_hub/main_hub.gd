extends Node2D
class_name MainHub

## now part of event bus
#signal main_hub_departed(selected_expedition: AreaData)

@onready var starting_pos_marker: Marker2D = $StartingPos
@onready var starting_pos: Vector2 = starting_pos_marker.global_position
@onready var signboard: MainHub_SignBoard = $signboard
##@onready var exit_door: ExitDoor = $ExitDoor

func _ready() -> void:
	SoundPlayer.play_music(SoundPlayer.music_base)
