extends Area2D
class_name Interact

## ideally this works without player knowing this comp

var closest_interactable: Interactable = null

@onready var p: Player = owner # i need disable controls
@onready var line: Line2D = $Line2D
@onready var t_update: Timer = $UpdateClosest

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


func _process(_delta: float) -> void:
	if not closest_interactable or p.PlayerInfo.team_alive == 0:
		line.hide()
		return
	line.show()
	line.points[0] = Vector2.ZERO
	line.points[1] = closest_interactable.global_position - global_position

func _physics_process(delta: float) -> void:
	pass
	#update arrows

func _unhandled_key_input(event: InputEvent) -> void:
	if p.controls_disabled or closest_interactable == null or p.PlayerInfo.team_alive == 0:
		EventBus.interacting = false
		return
	
	if event.is_action_pressed("interact") and closest_interactable:
		p.velocity = Vector2.ZERO
		EventBus.interacting = true
	elif event.is_action_released("interact"):
		EventBus.interacting = false


func _on_area_entered(_area: Area2D) -> void:
	_on_update_closest_timeout()


func _on_area_exited(_area: Area2D) -> void:
	_on_update_closest_timeout()


func _on_update_closest_timeout() -> void:
	if p.PlayerInfo.team_alive == 0:
		EventBus.interactable_detected.emit(null)
		return
	update_nearest_interactable()
	if closest_interactable:
		closest_interactable.select_this()
		t_update.one_shot = false
	else:
		EventBus.interactable_detected.emit(null)
