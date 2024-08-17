extends Node2D
class_name LevelManager

signal level_cleared

@export var DM: DungeonManager

@onready var chest_rune_holder: ChestRuneHolder = $ChestRuneHolder
@onready var enemy_holder: EnemyHolder = $EnemyHolder

@onready var starting_pos_marker: Marker2D = $StartingPos
@onready var starting_pos: Vector2 = starting_pos_marker.global_position
@onready var door: Marker2D = $Door


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	chest_rune_holder.DM = DM


func level_is_cleared() -> void:
	door.open()
	chest_rune_holder.open_all_chest_rune()
	level_cleared.emit()
