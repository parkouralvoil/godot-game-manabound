extends Node2D
class_name MainHub

signal main_hub_departed

@onready var starting_pos_marker: Marker2D = $StartingPos
@onready var starting_pos: Vector2 = starting_pos_marker.global_position
@onready var exit_door: ExitDoor = $ExitDoor


func _ready() -> void:
	exit_door.local_exit_door_interacted.connect(_on_local_exit_door_interacted)


func _on_local_exit_door_interacted() -> void:
	main_hub_departed.emit()
	# start game
