extends Node2D
class_name LevelManager

@onready var starting_pos: Vector2 = $StartingPos.global_position
@onready var door: Marker2D = $Door
@onready var enemy_holder: EnemyHolder = $EnemyHolder


signal level_cleared


func level_is_cleared() -> void:
	door.open()
	level_cleared.emit()
