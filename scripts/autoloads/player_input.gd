extends Node

## these signals are connected to CharacterManager.gd
# mobile
signal character_switch_left()
signal character_switch_right()

# pc
signal character_index_switch(index: int)

var want_to_choose_boost_direction: bool = false ## idle to move VS move to idle

var pressing_interact: bool = false
var pressing_attack: bool = false
var pressing_ult: bool = false

@onready var _mobile_controls: bool = \
		ProjectSettings.get_setting("application/run/MobileControlsEnabled")

func _process(_delta: float) -> void:
	if _mobile_controls:
		return ## Mobile wont use this

	pressing_attack = Input.is_action_pressed("left_click")
	pressing_ult = Input.is_action_pressed("right_click")

func _input(event: InputEvent) -> void:
	if _mobile_controls:
		return ## Mobile wont use this
	
	pressing_interact = Input.is_action_pressed("interact")

	if event.is_action_pressed("space"):
		want_to_choose_boost_direction = true
	elif event.is_action_released("space"):
		want_to_choose_boost_direction = false
	
	if event.is_action_pressed("1"):
		character_index_switch.emit(1)
	if event.is_action_pressed("2"):
		character_index_switch.emit(2)
	if event.is_action_pressed("3"):
		character_index_switch.emit(3)
	
	