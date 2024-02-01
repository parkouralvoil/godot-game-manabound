extends Node2D

var smalldrone_scene: PackedScene = load("res://scenes/enemies/enemy_smalldrone.tscn")

@onready var markers: Array[Marker2D] = [$Marker2D, $Marker2D2, $Marker2D3]

func spawn(drone: PackedScene, position: Vector2):
	var drone_instance := drone.instantiate()
	if drone_instance:
		drone_instance.global_position = position
		
		get_tree().root.add_child(drone_instance)
	elif drone_instance == null:
		print(drone)

func _on_spawn_timer_timeout():
	for i in markers:
		spawn(smalldrone_scene, i.global_position)
