extends State
class_name PlayerStance

# for charged abilities

@export var p: Player
var mouse_position: Vector2 = Vector2.ZERO
var recoil_speed: float = 200
var slow_speed: float = 20

func Enter() -> void:
	if !p:
		return
	p.gravity = 0
	if PlayerInfo.current_charge_type == PlayerInfo.ChargeTypes.BURST:
		p.direction_indicator.show()
		p.direction_indicator.circle.show()
	else:
		p.direction_indicator.show()
		p.direction_indicator.circle.hide()
	PlayerInfo.current_state = PlayerInfo.States.STANCE

func Exit() -> void:
	if !p:
		return
	p.velocity = recoil_speed * -p.move_direction

func Update(_delta: float) -> void:
	if !p:
		return
	#if p.velocity != Vector2.ZERO:
	
	flip_sprite()
	play_anim()

func Physics_Update(_delta: float) -> void:
	if !p:
		return
	if PlayerInfo.current_charge_type == PlayerInfo.ChargeTypes.BURST:
		p.velocity = slow_speed * -p.move_direction
	else:
		p.velocity = Vector2.ZERO
	
	if !Input.is_action_pressed("right_click"):
		state_transition.emit(self, "PlayerIdle")
	p.move_and_slide()

func flip_sprite() -> void:
	if p.velocity.x >= 1:
		p.anim_sprite.scale.x = -1
	elif p.velocity.x <= -1:
		p.anim_sprite.scale.x = 1

func play_anim() -> void:
	if p.anim_sprite.animation != "air":
		p.anim_sprite.play("air")
