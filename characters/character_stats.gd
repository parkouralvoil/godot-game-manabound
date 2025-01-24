extends Resource
class_name CharacterStats

@export_category("Initial Scalable Stats")
@export var INITIAL_MAX_HP: int = 5
@export var INITIAL_ATK: float = 10
@export var INITIAL_EP: float = 0 ## Elemental Profiency
@export var INITIAL_MAX_AMMO: int = 5

const base_charge_rate: float = 2 ## change this if u want stronger charge for all chars
@export var INITIAL_CHR: float = 100

## signals to connect for playerinfo
signal stats_changed
signal hp_changed 			## to see if char should die
signal max_charge_changed(new_max: float)	## for energy bar in panel char

## Scalable stats, have emitters
var max_hp: int = INITIAL_MAX_HP:
	set(value):
		max_hp = value
		stats_changed.emit()
var atk: float = INITIAL_ATK:
	set(val):
		atk = val
		stats_changed.emit()
var ep: float = INITIAL_EP:
	set(val):
		ep = val
		stats_changed.emit()
var chr: float = INITIAL_CHR:
	set(val):
		chr = val
		stats_changed.emit()
var max_ammo: int = INITIAL_MAX_AMMO:
	set(value):
		max_ammo = value
		stats_changed.emit()

## Dynamic stats, they change frequently
var hp: int:
	set(val):
		hp = val
		hp_changed.emit()
var ammo: int
var charge: float = 0:
	set(val):
		charge = clampf(val, 0, max_charge)

@export_category("Initial Ult Stats")
@export var INITIAL_MAX_CHARGE: float = 50			## how much charge can be stored
@export var INITIAL_CHARGE_THRESHOLD: float = 50 	## used for activating ult
@export var INITIAL_CHARGE_TIER: int = 1			## how many times charge can be spent in one ult activation

var max_charge: float = INITIAL_MAX_CHARGE:
	set(value):
		max_charge = clampf(value, 0, 9999)
		max_charge_changed.emit(max_charge)
var charge_threshold: float = INITIAL_CHARGE_THRESHOLD:
	set(value):
		charge_threshold = clampf(value, 0, max_charge)
		stats_changed.emit()
var charge_tiers: int = INITIAL_CHARGE_TIER: 
	set(tier):
		charge_tiers = clampi(tier, 1, 99)

@export_category("Kit Specific") 		## export variables in character
@export var reload_time: float = 0.5 	## seconds
@export var SPD: float = 400			## not yet used
@export var firerate: float = 7
@export var element: CombatManager.Elements = CombatManager.Elements.LIGHTNING
@export var melee: bool = false

func reset_stats() -> void: ## called by character scene, make sure no one else calls this...
	max_hp = INITIAL_MAX_HP
	hp = max_hp
	atk = INITIAL_ATK
	ep = INITIAL_EP
	chr = INITIAL_CHR
	charge = 0
	max_charge = INITIAL_MAX_CHARGE
	charge_threshold = INITIAL_CHARGE_THRESHOLD
	charge_tiers = INITIAL_CHARGE_TIER
	max_ammo = INITIAL_MAX_AMMO
	ammo = max_ammo
