extends State
class_name PlayerIdle
# when player is just idle on ground or faling in air
# can transition to all states
@export var p: Player

var air_deaccel: float = 50 #deacceleration
var recoil_speed: float = 10000

func _ready() -> void: 
	EventBus.interactable_held.connect(_switch_to_interact)

func Enter() -> void:
	if !p:
		return
	p.gravity = p.default_gravity
	p.direction_indicator.hide()
	p.circle_indicator.hide()
	p.PlayerInfo.current_state = PlayerInfoResource.States.IDLE
	p.PlayerInfo.input_ult = false


func Exit() -> void:
	if !p:
		return


func Update(_delta: float) -> void:
	if !p:
		return
	#if p.velocity != Vector2.ZERO:
	if not p.PlayerInfo.recoiling_from_basic_atk:
		flip_sprite()
	play_anim()
	_handle_inputs()


func Physics_Update(delta: float) -> void:
	if !p:
		return
	
	if p.controls_disabled:
		p.velocity = Vector2.ZERO
		return
	
	if not p.PlayerInfo.recoiling_from_basic_atk:
		if !p.is_on_floor():
			p.velocity.y = min(p.velocity.y + p.gravity * 0.626 * delta, p.gravity/1.5) ## gravity when player has no input
		if not PlayerInput.want_to_choose_boost_direction:
			p.circle_indicator.hide()
	else:
		if p.PlayerInfo.auto_aim and p.selected_target != null:
			if not p.PlayerInfo.melee_character:
				p.velocity.y -= (p.gravity * 0.3 * delta)
			else:
				pass
	
	horizontal_deaccel(delta)
	p.move_and_slide()
	# slow down player's speed xd

func _handle_inputs() -> void: ## since control UIs need to take click
	if p.controls_disabled:
		return
	
	if PlayerInput.want_to_choose_boost_direction: #prepare to boost
		state_transition.emit(self, "PlayerMove")
		p.PlayerInfo.recoiling_from_basic_atk = false
		p.circle_indicator.show()
	
	if PlayerInput.pressing_attack and not PlayerInput.want_to_choose_boost_direction:
		p.PlayerInfo.input_attack = true
	else:
		p.PlayerInfo.input_attack = false
	
	if PlayerInput.pressing_ult and p.PlayerInfo.can_use_ult:
		state_transition.emit(self, "PlayerStance")
	else:
		p.PlayerInfo.input_ult = false

func _switch_to_interact() -> void:
	state_transition.emit(self, "PlayerInteract")

func flip_sprite() -> void:
	if p.velocity.x >= 0:
		p.PlayerInfo.facing_direction = 1
	elif p.velocity.x < -0.1:
		p.PlayerInfo.facing_direction = -1


func play_anim() -> void:
	if p.velocity == Vector2.ZERO and p.is_on_floor():
		p.PlayerInfo.current_anim = "idle" #p.anim_sprite.play("idle")
	elif p.velocity.y > abs(p.velocity.x) and p.velocity.y > 225:
		p.PlayerInfo.current_anim = "fall" #p.anim_sprite.play("fall")
	elif p.PlayerInfo.recoiling_from_basic_atk:
		p.PlayerInfo.current_anim = "stance" #p.anim_sprite.play("stance")
	else:
		p.PlayerInfo.current_anim = "air" #p.anim_sprite.play("air")


func horizontal_deaccel(_delta: float) -> void:
	var multiplier: float = 1 if not p.is_on_floor() else 10
	if p.velocity.x >= 0:
		p.velocity.x = max(p.velocity.x - air_deaccel * multiplier * _delta, 0)
	
	if p.velocity.x < 0:
		p.velocity.x = min(p.velocity.x - air_deaccel * -multiplier * _delta, 0)
