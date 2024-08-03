extends Node2D
class_name LevelManager

signal level_cleared

@onready var starting_pos_marker: Marker2D = $StartingPos
@onready var starting_pos: Vector2 = starting_pos_marker.global_position
@onready var door: Marker2D = $Door
@onready var enemy_holder: EnemyHolder = $EnemyHolder


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE


func level_is_cleared() -> void:
	door.open()
	level_cleared.emit()
