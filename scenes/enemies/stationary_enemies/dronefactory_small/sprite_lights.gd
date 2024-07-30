extends Node2D
class_name FactoryAmmoComponent

var num_of_lights: int = 0
var lights_on: int = 0 : ## lights is ammo, full lights mean drone can spawn
	set(value):
		lights_on = value
		turn_on_light()

@onready var e: Enemy_DroneFactory = owner
@onready var lights: Array[Sprite2D] = []

func _ready() -> void:
	for child in get_children():
		if child is Sprite2D:
			lights.append(child)
			child.hide()
			num_of_lights += 1


func turn_on_light() -> void:
	var index: int = lights_on - 1
	var sp: Sprite2D = lights[index]
	sp.show()


func reset_lights() -> void:
	lights_on = 0
	for i in lights:
		i.hide()
