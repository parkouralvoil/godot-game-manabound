extends Resource
class_name PlayerInfoResource

## programmer's hunch
	## this autoload is important for all player systems to communicate properly
	## but making it an autoload also gives it access to other systems that should not be able to
	## affect the variables here, 
	## for now its ayt but its worth considering to put it as a "var preload" in the FUTURE

## OLD IDEA:
# teambuffing relic inventory
# overall, just makes communication between all scripts related to player easier
	# so im using it for states as well hehe

## I CANT MAKE THIS "script signal" ONLY, CUZ I NEED THE RESOURCE FOR SIGNALS
signal changed_buff_raw_atk
signal player_got_hit
signal drank_hp_potion
signal character_died(downed_char: DownedCharacter)
signal ult_finished(ult_recoil_dir: Vector2)

signal joystick_released(position: Vector2)

enum States {
	IDLE,
	MOVE,
	STANCE
}
var current_state: States = States.IDLE

## logic for inputs
var input_attack: bool = false
var input_ult: bool = false

## logic for recoil, stance stuff
var recoiling_from_basic_atk: bool = false # replaces "is_firing"
		## should rename this to (do recoil)
var can_use_ult: bool = true: # SET BY player.gd, determines if character can use ult/charge ult
	set(val):
		can_use_ult = val
		EventBus.can_ult_changed.emit(val)
var arm_animation_playing: bool = false # for chars that affect character arm

## set by player
var auto_aim: bool = true
var aim_direction: Vector2
var mouse_direction: Vector2
var target_position: Vector2 ## for deployable ults, mobile

## set by joystick if mobile controls enabled in project settings
var joystick_want_to_hover: bool
var joystick_direction: Vector2 

## set by characters abilities -> Rogue's BasicAtk
var melee_character: bool
var ult_need_circle_aim: bool ## witch, deployable ults, but might not be used anymore

## set by character script, for UI
var displayed_ammo: int
var displayed_MAX_AMMO: int
var current_charge: float    ## REWORK THIS!!! logic is using this...
var current_charge_threshold: float

## player to character:
var current_anim: String = "idle"
var facing_direction: int = 1

## character to player
var char_current_anim_sprite: AnimatedSprite2D
var char_current_sprite: Texture

## temporary buff effects:
var buff_raw_atk: float = 0:
	set(value):
		buff_raw_atk = value
		changed_buff_raw_atk.emit()
		#print_debug("emitted")

## Team Status (all team alive, last person dead), set by character manager of player
var team_size: int
var team_alive: int:
	set(val):
		team_alive = max(0, val)

var team_current_index: int = 0 # needed by swap char buttons

## READY FUNCTIONS DONT WORK HERE, cuz its a resource not a node
