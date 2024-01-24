extends State
class_name PlayerGround

@export var p: Player

func Enter():
	if !p:
		return
	p.airboost_input = false 
	p.airboost_ready = false

func Exit():
	if !p:
		return
	p.airboost_input = false 
	p.airboost_ready = false

func Update(_delta):
	if !p:
		return
	#if p.velocity != Vector2.ZERO:
		#state_transition.emit(self, "PlayerGround")
	p.x_movement = Input.get_axis("left", "right")
	p.y_movement = Input.get_axis("down", "up") # might have to inverse
	
	flip_sprite()
	play_anim()

func Physics_Update(_delta):
	if !p:
		return
	# horizontal movement
	if p.x_movement != 0:
		p.velocity.x = p.ground_speed * p.x_movement
	else:
		p.velocity.x = 0
	
	# ground jump
	if Input.is_action_just_pressed("space") and p.is_on_floor():
		p.velocity.y = p.jump_speed

	if !p.is_on_floor():
		state_transition.emit(self, "PlayerAir")
	p.move_and_slide()

func flip_sprite():
	if p.velocity.x >= 1:
		p.anim_sprite.scale.x = 1
	elif p.velocity.x <= -1:
		p.anim_sprite.scale.x = -1

func play_anim():
	if p.velocity == Vector2.ZERO and p.anim_sprite.animation != "idle":
		p.anim_sprite.play("idle")
	elif abs(p.velocity.x) >= 1 and p.anim_sprite.animation != "walk":
		p.anim_sprite.play("walk")
