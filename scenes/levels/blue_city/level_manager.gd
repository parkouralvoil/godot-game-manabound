extends Node2D
class_name LevelManager

@onready var starting_pos: Vector2 = $StartingPos.global_position
@onready var door: Marker2D = $Door
@onready var enemy_holder: EnemyHolder = $EnemyHolder


func open_door() -> void:
	door.open()
