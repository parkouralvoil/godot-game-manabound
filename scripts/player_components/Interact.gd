extends Area2D
class_name Interact

## ideally this works without player knowing this comp

var _closest_interactable: Interactable = null
static var can_interact: bool = false
var _tapped: bool = false
var _await_release_input: bool = false

@onready var p: Player = owner # i need disable controls
@onready var line: Line2D = $Line2D
@onready var t_update: Timer = $UpdateClosest

func update_nearest_interactable() -> void:
	_closest_interactable = null
	for inter in get_overlapping_areas():
		if _closest_interactable == null:
			_closest_interactable = inter
			continue
		
		var closest := _closest_interactable.global_position
		var new_pos := inter.global_position
		if global_position.distance_squared_to(
				closest) > global_position.distance_squared_to(new_pos):
			_closest_interactable = inter


func _process(_delta: float) -> void:
	if not _closest_interactable or p.PlayerInfo.team_alive == 0 or p.controls_disabled:
		can_interact = false
		line.hide()
		return
	line.show()
	line.points[0] = Vector2.ZERO
	line.points[1] = _closest_interactable.global_position - global_position

	can_interact = true

	if PlayerInput.pressing_interact:
		if _closest_interactable and not _tapped:
			if _closest_interactable.get_opens_ui(): # interact only when playerinput is let go
				_await_release_input = true
			else:
				_closest_interactable.interact()
			_tapped = true
	else:
		if _closest_interactable and _tapped:
			if _await_release_input:
				_closest_interactable.interact()
				_await_release_input = false
			_closest_interactable.release()
			_tapped = false

func _on_area_entered(_area: Area2D) -> void:
	_on_update_closest_timeout()


func _on_area_exited(_area: Area2D) -> void:
	_on_update_closest_timeout()


func _on_update_closest_timeout() -> void:
	if p.PlayerInfo.team_alive == 0:
		EventBus.interactable_detected.emit(null)
		return
	update_nearest_interactable()
	if _closest_interactable:
		_closest_interactable.select_this()
		t_update.one_shot = false
	else:
		EventBus.interactable_detected.emit(null)
