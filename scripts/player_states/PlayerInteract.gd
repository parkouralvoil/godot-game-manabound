extends State
class_name PlayerInteract
# when player is just idle on ground or faling in air
# can transition to all states
@export var p: Player

var air_deaccel: float = 200 #deacceleration
var recoil_speed: float = 10000

func _ready() -> void: 
	EventBus.interactable_finished.connect(func() -> void: state_transition.emit(self, "PlayerIdle"))


func Enter() -> void:
	if !p:
		return
	p.circle_indicator.show()
	p.PlayerInfo.current_state = PlayerInfoResource.States.IDLE
	p.PlayerInfo.input_attack = false
	p.PlayerInfo.input_ult = false
	

func Exit() -> void:
	if !p:
		return


func Update(_delta: float) -> void:
	if !p:
		return
	#if p.velocity != Vector2.ZERO:
	play_anim()


func Physics_Update(_delta: float) -> void:
	if !p:
		return
	p.velocity = Vector2.ZERO
	p.move_and_slide()
	#print("at interact state")
	if p.controls_disabled:
		return


func play_anim() -> void:
	p.PlayerInfo.current_anim = "stance"
