extends Node2D
class_name SpawnerComponent

@export var smalldrone_scene: PackedScene

@onready var e: DroneFactoryClass = owner

@onready var markers: Array[Marker2D] = [$Marker2D]
@onready var t_spawn: Timer = $spawn_timer

signal spawned_enemy
signal ammo_increased
var max_ammo: int = 8
var ammo: int = 0 : # the ammofication of everything (at max ammo, spawn an enemy)
	set(value):
		ammo = value
		ammo_increased.emit()
		# print("ammo: %d" % ammo)


func _ready() -> void:
	assert(smalldrone_scene, "i forgot to export drone")
	await get_tree().process_frame
	t_spawn.wait_time = e.reload_time
	t_spawn.start()


func _physics_process(delta: float) -> void:
	pass#print("time = %f" % t_spawn.wait_time)


func spawn(drone: PackedScene, pos: Vector2) -> void:
	var drone_instance: CharacterBody2D = drone.instantiate()
	spawned_enemy.emit()
	if drone_instance:
		drone_instance.global_position = pos
		
		get_tree().root.add_child(drone_instance)
	elif drone_instance == null:
		pass # print(drone)


func _on_spawn_timer_timeout() -> void:
	t_spawn.wait_time = e.reload_time # update on the next cycle
	ammo = (ammo % max_ammo) + 1
	if ammo == max_ammo:
		for i in markers:
			spawn(smalldrone_scene, i.global_position)
