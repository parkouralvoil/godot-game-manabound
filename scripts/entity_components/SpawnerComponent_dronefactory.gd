extends Node2D
class_name SpawnerComponent

@export var smalldrone_scene: PackedScene

@onready var e: BaseEnemy = owner
@onready var holder: EnemyHolder = owner.get_parent().get_parent() ## dronefactory to marker to enemyholder

@onready var markers: Array[Marker2D] = [$Marker2D]
@onready var t_spawn: Timer = $spawn_timer
@onready var ammo_comp: FactoryAmmoComponent = $AmmoComponent

## rather than having each dronefactory detect how many units they spawned
## we can have a global "drone counter" that sets the max # of drones to 20
## so more drone factories just means faster way to reach capacity

var max_ammo: int = 8
@onready var ammo: int = 0 : # the ammofication of everything (at max ammo, spawn an enemy)
	set(value):
		ammo = value
		ammo_comp.lights_on += 1
		# print("ammo: %d" % ammo)

func _ready() -> void:
	assert(smalldrone_scene, "i forgot to export drone")
	await get_tree().process_frame
	t_spawn.wait_time = e.reload_time
	t_spawn.start()


func spawn(drone: PackedScene, pos: Vector2) -> void:
	var drone_instance: NormalEnemy = drone.instantiate()
	EnemyAiManager.small_drones += 1
	if drone_instance:
		drone_instance.global_position = pos
		drone_instance.spawned_runtime = true
		drone_instance.top_level = true
		owner.get_parent().add_child(drone_instance) 
		## drones shouldnt be destroyed 
		## if their factory is destroyed
	elif drone_instance == null:
		pass # print(drone)


func _on_spawn_timer_timeout() -> void:
	t_spawn.wait_time = e.reload_time # update on the next cycle
	var can_spawn: bool = EnemyAiManager.small_drones < EnemyAiManager.max_drones
	ammo = (ammo % max_ammo) + 1
	if ammo == max_ammo:
		ammo_comp.reset_lights()
		if can_spawn:
			for i in markers:
				spawn(smalldrone_scene, i.global_position)
