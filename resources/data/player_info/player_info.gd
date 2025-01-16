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

enum States {
	IDLE,
	MOVE,
	STANCE
}
var current_state: States = States.IDLE

enum ChargeTypes { ## i wanna rename this UltTypes but too much hassle, CHARGE works alrdy
	CHARGE, ## previously BURST
	ENERGY, ## previously ACTIVE
	MANA ## previously PASSIVE
}
var current_charge_type: ChargeTypes = ChargeTypes.CHARGE

## logic for inputs
var input_attack: bool = false
var input_ult: bool = false

## logic for recoil, stance stuff
var basic_attacking: bool = false # replaces "is_firing"
		## should rename this to (do recoil)
var can_charge: bool = true # SET BY player.gd, determines if charactre can use ult/charge ult
var charging: bool = false # for ult
var ult_animation_playing: bool = false # stay in stance state (not moving) if char has ult anim

## set by player
var auto_aim: bool = true
var aim_direction: Vector2
var mouse_direction: Vector2

## set by characters abilities -> Rogue's BasicAtk
var melee_character: bool
var melee_aim_lock: bool
var ult_recoil: bool
var ult_need_circle_aim: bool ## witch, deployable ults

## set by character script, for UI
var displayed_ammo: int
var displayed_MAX_AMMO: int
var displayed_charge: float
var displayed_MAX_CHARGE: float
var displayed_HP: int
var displayed_MAX_HP: int

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

## READY FUNCTIONS DONT WORK HERE, cuz its a resource not a node
