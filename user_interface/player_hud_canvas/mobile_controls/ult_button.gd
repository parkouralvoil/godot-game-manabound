extends Control
class_name UltButton

## If the button is receiving inputs.
var is_pressed := false

# PRIVATE VARIABLES
var _touch_index : int = -1
var _can_ult: bool = true

@export var pressed_color := Color.GRAY
@export var disabled_color := Color(0.1, 0.1, 0.1, 0.5)

@onready var _base: Control = $Base
@onready var _fill: TextureRect = %fill
@onready var _default_color : Color = _base.modulate
@onready var _released_color: Color = _default_color

func _ready() -> void:
	EventBus.can_ult_changed.connect(_on_can_ult_changed)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if _is_point_inside_base(event.position) and _touch_index == -1:
				if _can_ult:
					_touch_index = event.index
					_base.modulate = pressed_color
					is_pressed = true
					PlayerInput.pressing_ult = true
				get_viewport().set_input_as_handled()
		elif event.index == _touch_index:
			_reset()
			get_viewport().set_input_as_handled()

func _on_can_ult_changed(new_can_ult: bool) -> void:
	_can_ult = new_can_ult
	_update_button_color()

func _update_button_color() -> void:
	if _can_ult:
		_released_color = _default_color
		_fill.show()
	else:
		_released_color = disabled_color
		_fill.hide()
	_base.modulate = _released_color

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
	PlayerInput.pressing_ult = false
	_touch_index = -1
	_update_button_color()
