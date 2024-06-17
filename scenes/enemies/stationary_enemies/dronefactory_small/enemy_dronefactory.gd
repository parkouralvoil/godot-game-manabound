extends BaseEnemy
class_name DroneFactoryClass


@export var spawner_comp: SpawnerComponent
@onready var sprite_lights: Node2D = $Sprite2D_main/sprite_lights

func _ready() -> void:
	super()
	spawner_comp.spawned_enemy.connect(_reset_lights)
	spawner_comp.ammo_increased.connect(_add_light)


func _reset_lights() -> void:
	sprite_lights.reset_lights()


func _add_light() -> void:
	sprite_lights.lights_on += 1
