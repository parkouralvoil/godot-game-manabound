extends State
class_name PlayerStance

# for charged abilities

@export var p: Player
var recoil_speed: float = 200
var slow_speed: float = 20

func Enter() -> void:
	if !p:
		return
	p.gravity = 0
	#p.direction_indicator.show()
	p.circle_indicator.show()
	p.direction_indicator.hide()
	p.PlayerInfo.current_state = PlayerInfoResource.States.STANCE
	p.PlayerInfo.input_ult = true

func Exit() -> void:
	if !p:
		return
	if p.PlayerInfo.ult_recoil:
		p.velocity = recoil_speed * -p.PlayerInfo.mouse_direction
	p.circle_indicator.position = Vector2(0, 0)
	p.PlayerInfo.input_ult = false

func Update(_delta: float) -> void:
	if !p:
		return
	#if p.velocity != Vector2.ZERO:
	
	flip_sprite()
	play_anim()

func Physics_Update(_delta: float) -> void:
	if !p:
		return
	if p.PlayerInfo.current_charge_type == PlayerInfoResource.ChargeTypes.CHARGE:
		p.velocity = slow_speed * p.move_direction
	else:
		p.velocity = Vector2.ZERO
		p.circle_indicator.position = p.dist_to_mouse
	
	p.circle_indicator.show()
	
	
	if !Input.is_action_pressed("right_click"):
		state_transition.emit(self, "PlayerIdle")
	p.move_and_slide()

func flip_sprite() -> void:
	if p.PlayerInfo.aim_direction.x > 0: ## ensure this is same as condition for aim_node in player's code
		p.anim_sprite.scale.x = 1
	else:
		p.anim_sprite.scale.x = -1

func play_anim() -> void:
	if p.anim_sprite.animation != "stance":
		p.anim_sprite.play("stance")
