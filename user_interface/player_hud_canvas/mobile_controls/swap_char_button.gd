extends Control
class_name SwapCharacterButton

## If the button is receiving inputs.
var is_pressed := false

# PRIVATE VARIABLES
var _touch_index : int = -1

@export var pressed_color := Color.GRAY
@export var disabled_color := Color(0.1, 0.1, 0.1, 0.5)
@export var swap_left: bool = true 

@onready var _base: Control = $Base
@onready var _arrow: TextureRect = %LeftArrow # also same for right, right just flips it in code
@onready var _default_color : Color = _base.modulate
@onready var _released_color: Color = _default_color

func _ready() -> void:
	if ProjectSettings.get_setting("input_devices/pointing/emulate_mouse_from_touch"):
		printerr("The Project Setting 'emulate_mouse_from_touch' should be set to False")
	if not ProjectSettings.get_setting("input_devices/pointing/emulate_touch_from_mouse"):
		printerr("The Project Setting 'emulate_touch_from_mouse' should be set to True")
	
	if not swap_left:
		_arrow.flip_h = true
	
	EventBus.swapped_character.connect(_on_swapped_character)
	EventBus.returned_to_mainhub.connect(_on_returned_to_mainhub)
	EventBus.tutorial_team_restriction_set.connect(_on_tutorial_team_restriction_set)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if _is_point_inside_base(event.position) and _touch_index == -1:
				_touch_index = event.index
				_base.modulate = pressed_color
				if not is_pressed:
					is_pressed = true
					if swap_left:
						PlayerInput.character_switch_left.emit()
					elif not swap_left:
						PlayerInput.character_switch_right.emit()
				get_viewport().set_input_as_handled()
		elif event.index == _touch_index:
			_reset()
			get_viewport().set_input_as_handled()

func _on_swapped_character(current_index: int, max_index: int) -> void:
	if not is_pressed:
		_update_button_color()

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
	_update_button_color()
	_touch_index = -1

func _update_button_color() -> void:
	if swap_left:
		_released_color = _default_color
	else:
		_released_color = _default_color
	_base.modulate = _released_color

func _on_returned_to_mainhub() -> void:
	show()

func _on_tutorial_team_restriction_set(level: int) -> void:
	if level == 1:
		hide()
	else:
		show()