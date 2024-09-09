extends Area2D
class_name Interact

## ideally this works without player knowing this comp

var closest_interactable: Interactable = null

@onready var p: Player = owner # i need disable controls
@onready var line: Line2D = $Line2D

func update_nearest_interactable() -> void:
	closest_interactable = null
	for inter in get_overlapping_areas():
		if closest_interactable == null:
			closest_interactable = inter
			continue
		
		var closest := closest_interactable.global_position
		var new_pos := inter.global_position
		if global_position.distance_squared_to(
				closest) > global_position.distance_squared_to(new_pos):
			closest_interactable = inter


func _physics_process(_delta: float) -> void:
	if not closest_interactable:
		line.hide()
		return
	line.show()
	line.points[0] = Vector2.ZERO
	line.points[1] = closest_interactable.global_position - global_position


func _unhandled_key_input(event: InputEvent) -> void:
	if p.controls_disabled or closest_interactable == null:
		return
	
	if event.is_action_pressed("interact"):
		pass


func _on_area_entered(_area: Area2D) -> void:
	_on_update_closest_timeout()


func _on_area_exited(_area: Area2D) -> void:
	_on_update_closest_timeout()


func _on_update_closest_timeout() -> void:
	update_nearest_interactable()
	if closest_interactable:
		closest_interactable.select_this()
	else:
		EventBus.interactable_detected.emit(null)
