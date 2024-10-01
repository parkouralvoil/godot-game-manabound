extends State
class_name PlayerInteract
# when player is just idle on ground or faling in air
# can transition to all states
@export var p: Player

var air_deaccel: float = 200 #deacceleration
var recoil_speed: float = 10000

func Enter() -> void:
	if !p:
		return
	p.circle_indicator.show()
	p.PlayerInfo.current_state = PlayerInfoResource.States.IDLE


func Exit() -> void:
	if !p:
		return
	EventBus.interacting = false


func Update(_delta: float) -> void:
	if !p:
		return
	#if p.velocity != Vector2.ZERO:
	if not EventBus.interacting:
		state_transition.emit(self, "PlayerIdle")
	play_anim()


func Physics_Update(delta: float) -> void:
	if !p:
		return
	p.velocity = Vector2.ZERO
	
	if p.controls_disabled:
		return
	p.move_and_slide()
	# slow down player's speed xd


#func _unhandled_input(event: InputEvent) -> void: ## since control UIs need to take click
	#if p.controls_disabled:
		#return
	#
	#if Input.is_action_pressed("space"): #prepare to boost
		#state_transition.emit(self, "PlayerMove")
		#p.PlayerInfo.basic_attacking = false
		#p.circle_indicator.show()
		#p.PlayerInfo.input_attack = false
	#
	#if event.is_action_pressed("left_click") and not Input.is_action_pressed("space"):
		#p.PlayerInfo.input_attack = true
	#
	#if event.is_action_released("left_click"):
		#p.PlayerInfo.input_attack = false
	#
	#if event.is_action_pressed("right_click") and p.PlayerInfo.can_charge:
		#state_transition.emit(self, "PlayerStance")


func play_anim() -> void:
	p.PlayerInfo.current_anim = "stance"
