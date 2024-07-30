extends Node2D
class_name SpawnerComponent

@export var smalldrone_scene: PackedScene

@onready var e: Enemy_DroneFactory = owner

@onready var markers: Array[Marker2D] = [$Marker2D]
@onready var t_spawn: Timer = $spawn_timer

signal spawned_enemy
signal ammo_increased

## rather than having each dronefactory detect how many units they spawned
## we can have a global "drone counter" that sets the max # of drones to 20
## so more drone factories just means faster way to reach capacity

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


func _physics_process(_delta: float) -> void:
	pass#print("time = %f" % t_spawn.wait_time)


func spawn(drone: PackedScene, pos: Vector2) -> void:
	var drone_instance: Enemy_SmallDrone = drone.instantiate()
	EnemyAiManager.small_drones += 1
	if drone_instance:
		drone_instance.global_position = pos
		drone_instance.spawned_runtime = true
		get_tree().root.add_child(drone_instance)
	elif drone_instance == null:
		pass # print(drone)


func _on_spawn_timer_timeout() -> void:
	t_spawn.wait_time = e.reload_time # update on the next cycle
	var can_spawn: bool = EnemyAiManager.small_drones < EnemyAiManager.max_drones
	ammo = (ammo % max_ammo) + 1
	if ammo == max_ammo:
		spawned_enemy.emit() ## this is just for lights
		if can_spawn:
			for i in markers:
				spawn(smalldrone_scene, i.global_position)
