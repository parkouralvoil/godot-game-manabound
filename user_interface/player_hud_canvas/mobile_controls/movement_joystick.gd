extends VirtualJoystick
class_name MovementJoystick

@export var PlayerInfo: PlayerInfoResource

func _update_joystick(touch_position: Vector2) -> void:
	var _base_radius := _get_base_radius()
	var center : Vector2 = _base.global_position + _base_radius
	var vector : Vector2 = touch_position - center
	vector = vector.limit_length(clampzone_size)
	
	if joystick_mode == Joystick_mode.FOLLOWING and touch_position.distance_to(center) > clampzone_size:
		_move_base(touch_position - vector)
	
	_move_tip(center + vector)
	
	if vector.length_squared() > deadzone_size * deadzone_size:
		is_pressed = true
		output = (vector - (vector.normalized() * deadzone_size)) / (clampzone_size - deadzone_size)
	else:
		is_pressed = false
		output = Vector2.ZERO
	
	PlayerInfo.joystick_want_to_hover = vector.length_squared() + 1 >= clampzone_size * clampzone_size
	PlayerInfo.joystick_direction = output
	PlayerInput.want_to_choose_boost_direction = true
	
	if use_input_actions: ## this should be set off in inspector
		pass

func _reset() -> void:
	is_pressed = false
	
	PlayerInfo.joystick_released.emit(output)
	PlayerInfo.joystick_want_to_hover = false
	PlayerInfo.joystick_direction = Vector2.ZERO
	PlayerInput.want_to_choose_boost_direction = false
	
	output = Vector2.ZERO
	_touch_index = -1
	_tip.modulate = _default_color
	_base.position = _base_default_position
	_tip.position = _tip_default_position
	# Release actions
	if use_input_actions:
		for action in [action_left, action_right, action_down, action_up]:
			if Input.is_action_pressed(action):
				Input.action_release(action)
