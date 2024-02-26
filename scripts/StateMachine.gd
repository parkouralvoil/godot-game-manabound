extends Node
class_name StateMachine

@export var initial_state : State

var states : Dictionary = {}
var current_state : State

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_transition.connect(change_state)
	
	if initial_state:
		initial_state.Enter()
		current_state = initial_state

func _process(delta: float) -> void:
	if current_state:
		current_state.Update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.Physics_Update(delta)

func change_state(state: State, new_state_name: String) -> void:
	if state != current_state:
		return
	
	var new_state: Variant = states.get(new_state_name.to_lower()) # type variant cuz dictionary sux
	if !new_state:
		return
	
	if current_state:
		current_state.Exit()
		
	new_state.Enter()
	current_state = new_state
