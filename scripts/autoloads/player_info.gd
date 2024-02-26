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
	ACTIVE,
	PASSIVE
}
var current_charge_type: ChargeTypes = ChargeTypes.BURST

var basic_attacking: bool = false # replaces "is_firing"
var can_charge: bool = true # for passive charge chars to set it false
var charging: bool = false # for ult

# set by enemies
var mana_orbs: int

# set by player
var aim_direction: Vector2
var mouse_direction: Vector2 

# set by player's AM, for UI
var displayed_ammo: int
var displayed_max_ammo: int
var displayed_charge: float
var displayed_max_charge: float
var displayed_health: float
var displayed_max_health: float

signal on_ammo_changed # ammo only
signal on_health_changed # hp only
signal on_max_changed # max ammo,hp,charge

# NO NEED for target lock var, aim_direction already handles it

func _ready() -> void:
	mana_orbs = 0
	on_ammo_changed.connect(_update_ammo)
	on_health_changed.connect(_update_health)
	on_max_changed.connect(_update_max)

func _process(_delta: float) -> void:
	match current_charge_type:
		ChargeTypes.BURST:
			can_charge = true
		ChargeTypes.ACTIVE:
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

func _update_max(max_ammo: int, max_health: float, max_charge: float) -> void:
	PlayerInfo.displayed_max_charge = max_charge
	PlayerInfo.displayed_max_health = max_health
	PlayerInfo.displayed_max_ammo = max_ammo
