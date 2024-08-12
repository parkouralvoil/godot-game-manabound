extends Resource
class_name CharacterStats

@export_category("Scalable Stats")
@export var MAX_HP: int = 5: ## technically HP but id need to rewrite character/player scripts
	set(value):
		MAX_HP = value
		max_HP_changed.emit()

## need to add "base" stats once i add the stat runes to increase stats

@export var ATK: float = 10
@export var EP: float = 0 ## Elemental Profiency
@export var CHR: float = 25 ## base charge rate, 

## Dynamic stats, they change frequently
var HP: int
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
#signal ATK_changed ## might need this afterall
#signal EP_changed
#signal reload_time_changed
#signal firerate_changed
#signal charge_rate_changed
