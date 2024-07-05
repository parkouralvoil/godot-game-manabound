extends Node2D
class_name EnemyHealthComponent

@export var damage_number: PackedScene
@export var enemy_explosion_sfx: AudioStream
@export var explosion_volume: float = -15
@onready var e: BaseEnemy = owner

@onready var element_indicator: ElementIndicator = $HBoxContainer/element_indicator
@onready var debuff_indicator: DebuffIndicator = $HBoxContainer/debuff_indicator
@onready var healthbar: ProgressBar = $Healthbar
@onready var HBox: HBoxContainer = $HBoxContainer

@export_category("Enemy Value")
@export var small_orbs: int = 2
@export var medium_orbs: int = 2

@export_category("Debuff Resources")
@export var crystalize_effect: Crystalized
@export var superconduct_effect: Superconduct
## OVERLOAD and MELT are builtin for now, 
	## but once i add ways to change reaction effects
	## they need to be relagated to debuff resources

var rng := RandomNumberGenerator.new()

var element_initial: CombatManager.Elements = CombatManager.Elements.NONE

var is_dead: bool = false
@onready var old_hp: float

func _ready() -> void:
	var healthbar_size: float = clampf(5.0 + (8.0 * (e.max_health/10.0) ), 1, 150)
	healthbar.size.x = healthbar_size
	healthbar.position.x = -healthbar_size/2
	HBox.position.x = -healthbar_size/2
	
	assert(damage_number, "forgot to export")
	await e.ready
	old_hp = e.max_health

#region Health Component
func damage_received(damage: float, new_elem: CombatManager.Elements) -> void:
	var inflicted_reaction: CombatManager.Reactions = CombatManager.Reactions.NONE
	
	if element_initial == CombatManager.Elements.NONE:
		element_initial = new_elem
		element_indicator.element = new_elem
	elif new_elem != CombatManager.Elements.NONE && new_elem != element_initial:
		inflicted_reaction = apply_reaction(new_elem)
		if inflicted_reaction == CombatManager.Reactions.MELT:
			damage = damage * 2
	
	if damage > 0:
		spawn_dmg_number(str(round(damage)), CombatManager.params[new_elem])
	
	if e.health - damage > 0:
		e.health -= damage
		if (old_hp - e.health) >= 5:
			produce_energy(old_hp - e.health)
			old_hp = e.health
	elif not is_dead:
		produce_energy(e.health)
		is_dead = true
		EventBus.enemy_died.emit(e)
		EnemyAiManager.spawn_orbs(global_position, small_orbs, medium_orbs)
		clear_debuff_references()
		SoundPlayer.play_sound_2D(global_position, enemy_explosion_sfx, explosion_volume + 7, 1.1)
		e.make_impact()
		e.queue_free()


func produce_energy(difference: float) -> void:
	var procs: int = roundi(difference / 5)
	EventBus.enemy_lost_5_hp.emit(procs)

func spawn_dmg_number(effect: String, color: Color) -> void:
	var pos_variance: Vector2
	var label_inst: Label = damage_number.instantiate()
	
	label_inst.text = effect
	label_inst.modulate = color
	
	if effect.is_valid_int():
		pos_variance = Vector2(rng.randf_range(-10, 10), rng.randf_range(-5, 5) )
	else:
		label_inst.speed = -20
		if effect == "Superconduct":
			pos_variance = Vector2(-33,-20)
		elif effect == "Melt":
			pos_variance = Vector2(-11,-20)
		elif effect == "Overload":
			pos_variance = Vector2(-21.5,-20)
		else:
			pos_variance = Vector2(-37,-20)
	
	label_inst.global_position = self.global_position + pos_variance
	get_tree().root.call_deferred("add_child", label_inst)


func apply_reaction(new_elem: CombatManager.Elements) -> CombatManager.Reactions:
	#print(CombatManager.Elements.keys()[element_initial] + " ||NEW: " 
	#+ CombatManager.Elements.keys()[new_elem])
	var reaction: CombatManager.Reactions = CombatManager.determine_reaction(element_initial, new_elem)
	match reaction:
		CombatManager.Reactions.MELT:
			spawn_dmg_number("Melt", CombatManager.params["melt"])
			## double damage dealt
		CombatManager.Reactions.SUPERCONDUCT:
			apply_debuff(CombatManager.Debuffs.SUPERCONDUCT)
			spawn_dmg_number("Superconduct", CombatManager.params["superconduct"])
		CombatManager.Reactions.OVERLOAD:
			spawn_dmg_number("Overload", CombatManager.params["overload"])
			spawn_overload_impact(global_position)
			## interrupt enemy charging attack (LASER, ORB)
				## enemy is interrupted by cancelling current fire cycle and
				## subtracting one ammo to force a reload
		_: ## NONE or other not yet implemented reactions
			pass
	element_initial = CombatManager.Elements.NONE
	element_indicator.element = CombatManager.Elements.NONE
	return reaction
#endregion


func spawn_overload_impact(pos: Vector2) -> void:
	var inst: DamageImpact = CombatManager.overload_impact.instantiate()
	inst.global_position = pos
	get_tree().root.call_deferred("add_child", inst)


#region Debuff Component
func apply_debuff(new_debuff: CombatManager.Debuffs) -> void:
	match new_debuff:
		CombatManager.Debuffs.SUPERCONDUCT:
			if superconduct_effect:
				superconduct_effect.apply_effect(self)
		CombatManager.Debuffs.CRYSTALIZED:
			if crystalize_effect:
				crystalize_effect.apply_effect(self)
		_:
			pass
	debuff_indicator.current_debuff = new_debuff


func clear_debuff_references() -> void:
	if crystalize_effect:
		crystalize_effect.delete_ref(self)
	if superconduct_effect:
		superconduct_effect.delete_ref(self)
#endregion
