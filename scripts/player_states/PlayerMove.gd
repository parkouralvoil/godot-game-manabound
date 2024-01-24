extends State
class_name PlayerMove
# when player wants to boost or just slowly float in air
# can transition back to idle after boosting or stance if attacking
# can acivate shield
@export var p: Player
var mouse_position: Vector2 = Vector2.ZERO
var boost_speed: float = 300
var slow_speed: float = 20

func Enter():
	if !p:
		return
	p.gravity = 0
	p.direction_indicator.show()

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
	p.velocity = slow_speed * p.aim_direction
	
	if Input.is_action_just_released("space"): #boost away
		p.velocity = boost_speed * p.aim_direction
		await get_tree().create_timer(0.1)
		state_transition.emit(self, "PlayerIdle")
	
	p.move_and_slide()

func flip_sprite():
	if p.velocity.x >= 1:
		p.anim_sprite.scale.x = 1
	elif p.velocity.x <= -1:
		p.anim_sprite.scale.x = -1

func play_anim():
	if p.anim_sprite.animation != "air":
		p.anim_sprite.play("air")
