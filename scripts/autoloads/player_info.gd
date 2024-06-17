extends Node
# already has the class name "PlayerInfo"

#programmer's hunch
	# this autoload is important for all player systems to communicate properly
	# but making it an autoload also gives it access to other systems that should not be able to
	# affect the variables here, 
	# for now its ayt but its worth considering to put it as a "var preload" in the FUTURE

# currency
# upgrades unlocked
# teambuffing relic inventory
# overall, just makes communication between all scripts related to player easier
	# so im using it for states as well hehe

enum States {
	IDLE,
	MOVE,
	STANCE
}
var current_state: States = States.IDLE

enum ChargeTypes {
	BURST,
	ENERGY,
	PASSIVE
}
var current_charge_type: ChargeTypes = ChargeTypes.BURST

## logic for inputs
var input_attack: bool = false
var input_ult: bool = false

## logic for recoil, stance stuff
var basic_attacking: bool = false # replaces "is_firing"
		## should rename this to (do recoil)
var can_charge: bool = true # for passive charge chars to set it false
var charging: bool = false # for ult

var mana_orbs: int = 0

# set by player
var aim_direction: Vector2
var mouse_direction: Vector2

# set by characters
var melee_character: bool
var melee_aim_lock: bool

# set by player's AM, for UI
var displayed_ammo: int
var displayed_max_ammo: int
var displayed_charge: float
var displayed_max_charge: float
var displayed_health: float
var displayed_max_health: float

signal on_ammo_changed # ammo only
signal on_health_changed # hp only
signal on_max_ammo_changed 
signal on_max_health_changed
signal on_max_charge_changed

# store references to previou ability managers (reset to null once like exit game or smthg)


# NO NEED for target lock var, aim_direction already handles it

func _ready() -> void:
	mana_orbs = 0
	on_ammo_changed.connect(_update_ammo)
	on_health_changed.connect(_update_health)
	on_max_ammo_changed.connect(_update_max_ammo)
	on_max_health_changed.connect(_update_max_health)
	on_max_charge_changed.connect(_update_max_charge)
	
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	# might be better to centralize input in player process or in an input_manager node?
	match current_charge_type:
		ChargeTypes.BURST:
			can_charge = true
		ChargeTypes.ENERGY:
			pass
		ChargeTypes.PASSIVE:
			if displayed_charge < displayed_max_charge:
				can_charge = false
			else:
				can_charge = true

func _update_ammo(ammo: int) -> void:
	PlayerInfo.displayed_ammo = ammo

func _update_health(health: int) -> void:
	PlayerInfo.displayed_health = health

func _update_max_ammo(max_ammo: int) -> void:
	PlayerInfo.displayed_max_ammo = max_ammo

func _update_max_health(max_health: int) -> void:
	PlayerInfo.displayed_max_health = max_health

func _update_max_charge(max_charge: float) -> void:
	PlayerInfo.displayed_max_charge = max_charge

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cheat_menu"):
		mana_orbs += 10000
