extends State
class_name PlayerIdle
# when player is just idle on ground or faling in air
# can transition to all states
@export var p: Player

var air_deaccel: float = 200 #deacceleration

func Enter() -> void:
	if !p:
		return
	p.gravity = p.default_gravity
	p.direction_indicator.hide()
	PlayerInfo.current_state = PlayerInfo.States.IDLE

func Exit() -> void:
	if !p:
		return

func Update(_delta: float) -> void:
	if !p:
		return
	#if p.velocity != Vector2.ZERO:
	
	flip_sprite()
	play_anim()

func Physics_Update(_delta: float) -> void:
	if !p:
		return
	
	if Input.is_action_pressed("space") and !PlayerInfo.basic_attacking: #prepare to boost
		state_transition.emit(self, "PlayerMove")
	if Input.is_action_pressed("right_click") and PlayerInfo.can_charge:
		state_transition.emit(self, "PlayerStance")
	
	if !p.is_on_floor() and !PlayerInfo.basic_attacking:
		p.velocity.y = min(p.velocity.y + p.gravity * _delta, p.gravity)
	elif PlayerInfo.basic_attacking:
		if p.auto_aim and p.selected_target != null:
			p.velocity.y -= p.gravity * 0.3 * _delta
		else:
			p.velocity = Vector2.ZERO
	
	horizontal_deaccel(_delta)
	p.move_and_slide()
	# slow down player's speed xd

func flip_sprite() -> void:
	if p.velocity.x >= 1:
		p.anim_sprite.scale.x = 1
	elif p.velocity.x <= -1:
		p.anim_sprite.scale.x = -1

func play_anim() -> void:
	if p.velocity == Vector2.ZERO and p.is_on_floor():
		p.anim_sprite.play("idle")
	elif (abs(p.velocity.x) >= 1 or !p.is_on_floor()):
		p.anim_sprite.play("air")

func horizontal_deaccel(_delta: float) -> void:
	if p.velocity.x >= 0:
			p.velocity.x = max(p.velocity.x - air_deaccel * 1 * _delta, 0)
	if p.velocity.x < 0:
		p.velocity.x = min(p.velocity.x - air_deaccel * -1 * _delta, 0)
