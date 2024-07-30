extends BaseEnemy
class_name Enemy_DroneFactory


@export var spawner_comp: SpawnerComponent

@onready var ammo_comp: FactoryAmmoComponent = $Sprite2D_main/AmmoComponent

func _ready() -> void:
	super()
	spawner_comp.spawned_enemy.connect(_reset_lights)
	spawner_comp.ammo_increased.connect(_add_light)


func _reset_lights() -> void:
	ammo_comp.reset_lights()


func _add_light() -> void:
	ammo_comp.lights_on += 1
