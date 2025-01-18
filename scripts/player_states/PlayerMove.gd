extends State
class_name PlayerMove
# when player wants to boost or just slowly float in air
# can transition back to idle after boosting or stance if attacking
# can acivate shield
@export var p: Player
var boost_speed: float = 300
var slow_speed: float = 20

var boost_afterimages: int = 1

func _ready() -> void: 
	EventBus.interactable_held.connect(func() -> void: state_transition.emit(self, "PlayerInteract"))
	if p:
		p.PlayerInfo.joystick_released.connect(_boost_away)

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
	
	if PlayerInput.pressing_attack or PlayerInput.pressing_interact: ## shooting
		state_transition.emit(self, "PlayerIdle")
	
	flip_sprite()
	play_anim()


func Physics_Update(_delta: float) -> void:
	if !p:
		return
	p.velocity = slow_speed * p.move_direction
	
	if !PlayerInput.want_to_choose_boost_direction and not p.mobile_controls: #boost away
		_boost_away(p.PlayerInfo.mouse_direction)
	elif PlayerInput.pressing_ult and p.PlayerInfo.can_use_ult:
		state_transition.emit(self, "PlayerStance")
	
	p.move_and_slide()

func _boost_away(dir: Vector2) -> void:
	p.velocity = boost_speed * dir.normalized()
	p.afterimage_comp.afterimages = boost_afterimages
	p.emit_boost_effects(p.PlayerInfo.mouse_direction)
	state_transition.emit(self, "PlayerIdle")

func flip_sprite() -> void:
	if p.velocity.x >= 1:
		p.PlayerInfo.facing_direction = 1
	elif p.velocity.x <= -1:
		p.PlayerInfo.facing_direction = -1


func play_anim() -> void:
	if abs(p.velocity.y) > abs(p.velocity.x) and p.velocity.y > 225:
		p.PlayerInfo.current_anim = "fall" #p.anim_sprite.play("fall")
	elif PlayerInput.want_to_choose_boost_direction:
		p.PlayerInfo.current_anim = "stance" #p.anim_sprite.play("stance")
	else:
		p.PlayerInfo.current_anim = "air" #p.anim_sprite.play("air")
