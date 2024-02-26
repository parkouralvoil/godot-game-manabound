extends Node2D
class_name SpawnerComponent

@export var smalldrone_scene: PackedScene

@onready var e: BaseEnemy= owner

@onready var markers: Array[Marker2D] = [$Marker2D, $Marker2D2]
@onready var t_spawn: Timer = $spawn_timer

func _ready() -> void:
	assert(smalldrone_scene, "i forgot to export?")

func _process(delta: float) -> void:
	t_spawn.wait_time = e.reload_time

func spawn(drone: PackedScene, pos: Vector2) -> void:
	var drone_instance: CharacterBody2D = drone.instantiate()
	if drone_instance:
		drone_instance.global_position = pos
		
		get_tree().root.add_child(drone_instance)
	elif drone_instance == null:
		print(drone)

func _on_spawn_timer_timeout() -> void:
	for i in markers:
		spawn(smalldrone_scene, i.global_position)
