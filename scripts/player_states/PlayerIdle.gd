extends State
class_name PlayerIdle
# when player is just idle on ground or faling in air
# can transition to all states
@export var p: Player

var air_deaccel: float = 200 #deacceleration

func Enter():
	if !p:
		return
	p.gravity = p.default_gravity
	p.direction_indicator.hide()

func Exit():
	if !p:
		return

func Update(_delta):
	if !p:
		return
	#if p.velocity != Vector2.ZERO:
	
	flip_sprite()
	play_anim()

func Physics_Update(_delta):
	if !p:
		return
	
	if Input.is_action_pressed("space"): #prepare to boost
		state_transition.emit(self, "PlayerMove")
	
	if !p.is_on_floor():
		p.velocity.y += p.gravity * _delta
	
	horizontal_deaccel(_delta)
	p.move_and_slide()
	# slow down player's speed xd

func flip_sprite():
	if p.velocity.x >= 1:
		p.anim_sprite.scale.x = 1
	elif p.velocity.x <= -1:
		p.anim_sprite.scale.x = -1

func play_anim():
	if p.velocity == Vector2.ZERO and p.anim_sprite.animation != "idle":
		p.anim_sprite.play("idle")
	elif abs(p.velocity.x) >= 1 and p.anim_sprite.animation != "air":
		p.anim_sprite.play("air")

func horizontal_deaccel(_delta):
	if p.velocity.x >= 0:
			p.velocity.x = max(p.velocity.x - air_deaccel * 1 * _delta, 0)
	if p.velocity.x < 0:
		p.velocity.x = min(p.velocity.x - air_deaccel * -1 * _delta, 0)
