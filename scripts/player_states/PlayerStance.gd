extends State
class_name PlayerStance

# for charged abilities

@export var p: Player
var mouse_position: Vector2 = Vector2.ZERO
var boost_speed: float = 300
var slow_speed: float = 20

func Enter():
	if !p:
		return
	p.gravity = 0
	p.direction_indicator.show()
	p.current_state = p.States.STANCE

func Exit():
	if !p:
		return
	p.velocity = boost_speed/2 * -p.move_direction

func Update(_delta):
	if !p:
		return
	#if p.velocity != Vector2.ZERO:
	
	flip_sprite()
	play_anim()

func Physics_Update(_delta):
	if !p:
		return
	p.velocity = slow_speed * -p.move_direction
	
	if !Input.is_action_pressed("right_click"):
		state_transition.emit(self, "PlayerIdle")
	p.move_and_slide()

func flip_sprite():
	if p.velocity.x >= 1:
		p.anim_sprite.scale.x = -1
	elif p.velocity.x <= -1:
		p.anim_sprite.scale.x = 1

func play_anim():
	if p.anim_sprite.animation != "air":
		p.anim_sprite.play("air")
