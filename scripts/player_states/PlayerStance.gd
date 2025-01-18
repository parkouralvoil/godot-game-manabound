extends State
class_name PlayerStance

# for charged abilities

@export var p: Player
var recoil_speed: float = 200
var slow_speed: float = 20

func _ready() -> void:
	p.PlayerInfo.ult_finished.connect(_on_ult_finished)

func Enter() -> void:
	if !p:
		return
	p.gravity = 0
	#p.direction_indicator.show()
	#p.circle_indicator.show()
	#p.direction_indicator.hide()
	p.PlayerInfo.current_state = PlayerInfoResource.States.STANCE
	p.PlayerInfo.input_ult = true


func Exit() -> void:
	if !p:
		return
	#p.circle_indicator.position = Vector2(0, 0)
	p.PlayerInfo.input_ult = false
	print_debug("exited")


func Update(_delta: float) -> void:
	if !p:
		return
	
	flip_sprite()
	play_anim()
	
	if p.controls_disabled:
		state_transition.emit(self, "PlayerIdle")

func Physics_Update(_delta: float) -> void:
	if !p:
		return
	# if p.PlayerInfo.ult_need_circle_aim: 
	# 	p.velocity = Vector2.ZERO
	# 	p.circle_indicator.position = p.dist_to_mouse
	# else:
	# 	p.velocity = slow_speed * p.move_direction
	
	p.velocity = Vector2.ZERO
	p.circle_indicator.show()
	
	p.move_and_slide()

func _on_ult_finished(recoil_dir: Vector2) -> void:
	if recoil_dir != Vector2.ZERO:
		p.velocity = recoil_speed * -recoil_dir
	state_transition.emit(self, "PlayerIdle")

func flip_sprite() -> void:
	if p.PlayerInfo.aim_direction.x >= 0: ## ensure this is same as condition for aim_node in player's code
		p.PlayerInfo.facing_direction = 1
	else:
		p.PlayerInfo.facing_direction = -1


func play_anim() -> void:
	p.PlayerInfo.current_anim = "stance" #p.anim_sprite.play("stance")
