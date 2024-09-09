extends Resource
class_name CharacterStats

@export_category("Scalable Stats")
@export var initial_MAX_HP: int = 5
@export var initial_ATK: float = 10
@export var initial_EP: float = 0 ## Elemental Profiency
@export_category("Base Charge Rate (scaled by CHR)")
@export var base_charge_rate: float = 25 ## base charge rate, 
var initial_CHR: float = 100

var MAX_HP: int = initial_MAX_HP:
	set(value):
		MAX_HP = value
		max_HP_changed.emit()
		stats_changed.emit()
var ATK: float = initial_ATK:
	set(val):
		ATK = val
		stats_changed.emit()
var EP: float = initial_EP:
	set(val):
		EP = val
		stats_changed.emit()
var CHR: float = initial_CHR:
	set(val):
		CHR = val
		stats_changed.emit()

## Dynamic stats, they change frequently
var HP: int:
	set(val):
		HP = val
		HP_changed.emit()
var ammo: int
var charge: float = 0

@export_category("Unique Stats")
var MAX_CHARGE: float = 50:
	set(value):
		MAX_CHARGE = value
		max_HP_changed.emit()

@export var charge_tier: charge_tiers = charge_tiers.ONE:
	set(tier):
		charge_tier = tier
		MAX_CHARGE = (50 * (tier+1))
		max_charge_changed.emit()

@export var MAX_AMMO: int = 7:
	set(value):
		MAX_AMMO = value
		max_ammo_changed.emit()

@export var reload_time: float = 0.5 ## seconds
@export var SPD: float = 400 ## not yet used

@export_category("Kit Specific") ## export variables in character
@export var firerate: float = 7
@export var charge_type: PlayerInfoResource.ChargeTypes = PlayerInfoResource.ChargeTypes.CHARGE
@export var element: CombatManager.Elements = CombatManager.Elements.LIGHTNING
@export var melee: bool = false

enum charge_tiers{
	ONE,
	TWO,
	THREE,
}

## signals to connect for playerinfo
# commented lines indicate "no need cuz it updates properly na
signal max_HP_changed
signal max_charge_changed
signal max_ammo_changed

signal stats_changed
signal HP_changed ## to see if char should die

func reset_stats() -> void: ## called by character scene
	MAX_HP = initial_MAX_HP
	HP = MAX_HP
	ATK = initial_ATK
	EP = initial_EP
	CHR = initial_CHR
	ammo = MAX_AMMO
#signal ATK_changed ## might need this afterall
#signal EP_changed
#signal reload_time_changed
#signal firerate_changed
#signal charge_rate_changed
