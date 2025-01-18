extends Control
class_name AttackInteractButton

## If the button is receiving inputs.
var is_pressed := false

# PRIVATE VARIABLES
var _touch_index : int = -1

@export var pressed_color := Color.GRAY

@onready var _base: Control = $Base
@onready var _attack_icon: TextureRect = %attack
@onready var _interact_icon: TextureRect = %interact
@onready var _default_color : Color = _base.self_modulate

@onready var mobile_controls: bool = \
		ProjectSettings.get_setting("application/run/MobileControlsEnabled")

func _ready() -> void:
	if ProjectSettings.get_setting("input_devices/pointing/emulate_mouse_from_touch"):
		printerr("The Project Setting 'emulate_mouse_from_touch' should be set to False")
	if not ProjectSettings.get_setting("input_devices/pointing/emulate_touch_from_mouse"):
		printerr("The Project Setting 'emulate_touch_from_mouse' should be set to True")

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if _is_point_inside_base(event.position) and _touch_index == -1:
				_touch_index = event.index
				_base.self_modulate = pressed_color
				is_pressed = true
				get_viewport().set_input_as_handled()
		elif event.index == _touch_index:
			_reset()
			get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	if not mobile_controls:
		return
	
	if Interact.can_interact: ## is a static var of interact
		_interact_icon.show()
		_attack_icon.hide()
		PlayerInput.pressing_interact = is_pressed
		PlayerInput.pressing_attack = false
		# if interact will open UI, wait 1 frame then _reset()
	else:
		_interact_icon.hide()
		_attack_icon.show()
		PlayerInput.pressing_interact = false
		PlayerInput.pressing_attack = is_pressed

func _get_base_radius() -> Vector2:
	return _base.size * _base.get_global_transform_with_canvas().get_scale() / 2

func _is_point_inside_base(point: Vector2) -> bool:
	var _base_radius := _get_base_radius()
	var center : Vector2 = _base.global_position + _base_radius
	var vector : Vector2 = point - center
	if vector.length_squared() <= _base_radius.x * _base_radius.x:
		return true
	else:
		return false

func _reset() -> void:
	is_pressed = false
	_touch_index = -1
	_base.self_modulate = _default_color
