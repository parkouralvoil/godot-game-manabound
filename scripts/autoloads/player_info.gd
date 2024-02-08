extends Node
# already has the class name "PlayerInfo"

#programmer's hunch
	# this autoload is important for all player systems to communicate properly
	# but making it an autoload also gives it access to other systems that should not be able to
	# affect the variables here, 
	# for now its ayt but its worth considering to put it as a "const preload" in the FUTURE

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

var basic_attacking: bool = false # replaces "is_firing"
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

# NO NEED for target lock var, aim_direction already handles it

func _ready():
	mana_orbs = 0
