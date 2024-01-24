extends State
class_name PlayerAir

@export var p: Player

func Enter():
	if !p:
		return
	p.airboost_ready = false
	p.gravity = p.default_gravity

func Exit():
	if !p:
		return
	p.airboost_ready = false
	p.gravity = p.default_gravity

func Update(_delta):
	if !p:
		return
	p.x_movement = Input.get_axis("left", "right")
	p.y_movement = Input.get_axis("up", "down") # might have to inverse
	
	flip_sprite()
	play_anim()

func Physics_Update(_delta):
	if !p:
		return
	
	airboost_logic(_delta)
	horizontal_movement(_delta)
	if !p.is_on_floor():
		p.velocity.y += p.gravity * _delta
	elif p.is_on_floor():
		state_transition.emit(self, "PlayerGround")
	
	p.move_and_slide()

func flip_sprite():
	if p.velocity.x >= 1 and p.x_movement == 1:
		p.anim_sprite.scale.x = 1
	elif p.velocity.x <= -1 and p.x_movement == -1:
		p.anim_sprite.scale.x = -1

func play_anim():
	if p.anim_sprite.animation != "air":
		p.anim_sprite.play("air")

func horizontal_movement(_delta):
	if p.x_movement == 1:
		p.velocity.x = min(p.velocity.x + p.air_accel * 1 * _delta, p.airboost_speed * 1)
	elif p.x_movement == -1:
		p.velocity.x = max(p.velocity.x + p.air_accel * -1 * _delta, p.airboost_speed * -1)
	else:
		if p.velocity.x >= 0:
			p.velocity.x = max(p.velocity.x - p.air_accel * 1 * _delta, 0)
		if p.velocity.x < 0:
			p.velocity.x = min(p.velocity.x - p.air_accel * -1 * _delta, 0)

func airboost_logic(_delta):
	#1st lock
	if Input.is_action_just_released("space") and !p.airboost_ready:
		p.airboost_ready = true
	#2nd lock
	if Input.is_action_pressed("space") and p.airboost_ready:
		p.velocity = Vector2.ZERO
		p.gravity = 0
		p.airboost_input = true
	#3rd lock
	if Input.is_action_just_released("space") and p.airboost_input:
		if p.x_movement != 0 && p.y_movement != 0:
			p.velocity.x = p.airboost_speed * p.x_movement * 0.5
			p.velocity.y = p.airboost_speed * p.y_movement * 0.7
		elif p.x_movement != 0 && p.y_movement == 0:
			p.velocity.x = p.airboost_speed * p.x_movement * 0.8
			p.velocity.y = p.airboost_speed * -0.4
		elif p.y_movement == -1 or p.y_movement == 0:
			p.velocity.y = p.airboost_speed * -1
		else: # dash downwards
			p.velocity.y = p.airboost_speed * 0.8
		p.airboost_input = false
		p.gravity = p.default_gravity
