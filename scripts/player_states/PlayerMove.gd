extends State
class_name PlayerMove
# when player wants to boost or just slowly float in air
# can transition back to idle after boosting or stance if attacking
# can acivate shield
@export var p: Player
var boost_speed: float = 400
var slow_speed: float = 20

var boost_afterimages: int = 1

func _ready() -> void: 
	EventBus.interactable_held.connect(func() -> void: state_transition.emit(self, "PlayerInteract"))

func Enter() -> void:
	if !p:
		return
	p.gravity = 0
	p.direction_indicator.show()
	p.circle_indicator.show()
	p.PlayerInfo.current_state = PlayerInfoResource.States.MOVE
	p.PlayerInfo.input_ult = false
	p.PlayerInfo.input_attack = false


func Exit() -> void:
	if !p:
		return


func Update(_delta: float) -> void:
	if !p:
		return
	#if p.velocity != Vector2.ZERO:
	
	if p.controls_disabled:
		state_transition.emit(self, "PlayerIdle")
	
	if Input.is_action_just_pressed("left_click"):
		state_transition.emit(self, "PlayerIdle")
	
	flip_sprite()
	play_anim()


func Physics_Update(_delta: float) -> void:
	if !p:
		return
	p.velocity = slow_speed * p.move_direction
	
	if !Input.is_action_pressed("space"): #boost away
		p.velocity = boost_speed * p.PlayerInfo.mouse_direction
		p.afterimage_comp.afterimages = boost_afterimages
		p.emit_boost_effects(p.PlayerInfo.mouse_direction)
		state_transition.emit(self, "PlayerIdle")
	elif Input.is_action_pressed("right_click") and p.PlayerInfo.can_charge:
		state_transition.emit(self, "PlayerStance")
	
	p.move_and_slide()


func flip_sprite() -> void:
	if p.velocity.x >= 1:
		p.PlayerInfo.facing_direction = 1
	elif p.velocity.x <= -1:
		p.PlayerInfo.facing_direction = -1


func play_anim() -> void:
	if abs(p.velocity.y) > abs(p.velocity.x) and p.velocity.y > 225:
		p.PlayerInfo.current_anim = "fall" #p.anim_sprite.play("fall")
	elif Input.is_action_pressed("space"):
		p.PlayerInfo.current_anim = "stance" #p.anim_sprite.play("stance")
	else:
		p.PlayerInfo.current_anim = "air" #p.anim_sprite.play("air")
