extends Node2D
class_name Rogue_AbilityManager

@onready var character: Character = owner

## components
@onready var BasicAttack: Rogue_AttackComponent = $BasicAttack
@onready var Ultimate: Rogue_UltimateComponent = $Ultimate
@onready var Ammo: Rogue_AmmoComponent = $Ammo

var melee_dmg: float = 10

var ranged_dmg: float = 5
var bullet_speed: float = 400
var ranged_max_distance: float = 275

#@onready var skill_tree: SkillTree = $SkillTree

func _ready() -> void:
	character = owner
	BasicAttack.PlayerInfo = character.PlayerInfo
	Ultimate.PlayerInfo = character.PlayerInfo
	Ammo.PlayerInfo = character.PlayerInfo
	EventBus.enemy_lost_5_hp.connect(onfield_energy_production)

func onfield_energy_production(procs: int) -> void:
	if not character:
		print("ERROR ON ROGUE AM")
		return
	
	var base_energy_prod: float = 1
	character.charge = clampf(character.charge + base_energy_prod * procs, 
		0, character.max_charge)
	## WAYS TO PRODUCE ENERGY:
		## EVERY 5 DMG ON ENEMY GIVES 1 ENERGY
		## ENEMY DEATH GIVES 3 ENERGY
