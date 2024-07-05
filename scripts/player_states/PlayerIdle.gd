extends State
class_name PlayerIdle
# when player is just idle on ground or faling in air
# can transition to all states
@export var p: Player

var air_deaccel: float = 200 #deacceleration
var recoil_speed: float = 10000

func Enter() -> void:
	if !p:
		return
	p.gravity = p.default_gravity
	p.direction_indicator.hide()
	p.circle_indicator.hide()
	p.PlayerInfo.current_state = PlayerInfoResource.States.IDLE

func Exit() -> void:
	if !p:
		return

func Update(_delta: float) -> void:
	if !p:
		return
	#if p.velocity != Vector2.ZERO:
	
	if not p.PlayerInfo.basic_attacking:
		flip_sprite()
	play_anim()

func Physics_Update(delta: float) -> void:
	if !p:
		return
	
	if Input.is_action_pressed("space"): #prepare to boost
		state_transition.emit(self, "PlayerMove")
		p.PlayerInfo.basic_attacking = false
		p.circle_indicator.show()
		p.PlayerInfo.input_attack = false
	else:
		p.PlayerInfo.input_attack = Input.is_action_pressed("left_click")
	if Input.is_action_pressed("right_click") and p.PlayerInfo.can_charge:
		state_transition.emit(self, "PlayerStance")
	
	if not p.PlayerInfo.basic_attacking:
		if !p.is_on_floor():
			p.velocity.y = min(p.velocity.y + p.gravity * delta, p.gravity/1.25) ## gravity when player has no input
		if not Input.is_action_pressed("space"):
			p.circle_indicator.hide()
	else:
		if p.auto_aim and p.selected_target != null:
			if not p.PlayerInfo.melee_character:
				p.velocity.y -= (p.gravity * 0.3 * delta)
			else:
				pass
	
	horizontal_deaccel(delta)
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
	elif p.velocity.y > abs(p.velocity.x) and p.velocity.y > 225:
		p.anim_sprite.play("fall")
	elif p.PlayerInfo.basic_attacking:
		p.anim_sprite.play("stance")
	else:
		p.anim_sprite.play("air")

func horizontal_deaccel(_delta: float) -> void:
	if p.velocity.x >= 0:
			p.velocity.x = max(p.velocity.x - air_deaccel * 1 * _delta, 0)
	if p.velocity.x < 0:
		p.velocity.x = min(p.velocity.x - air_deaccel * -1 * _delta, 0)
