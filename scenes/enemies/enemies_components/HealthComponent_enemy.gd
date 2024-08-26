extends Node2D
class_name EnemyHealthComponent

@export var damage_number: PackedScene
@export var enemy_explosion_sfx: AudioStream
@export var explosion_volume: float = -15

@export_category("Debuff Resources")
@export var crystalize_effect: Crystalized
@export var superconduct_effect: Superconduct
## OVERLOAD and MELT are builtin for now, 
	## but once i add ways to change reaction effects
	## they need to be relagated to debuff resources

var rng := RandomNumberGenerator.new()
var element_initial: CombatManager.Elements = CombatManager.Elements.NONE
var is_dead: bool = false

## healthbar colors
var color_tier1 := Color(1, 0.21, 0.32)
var color_tier2 := Color(1, 0.4, 0.015)
var color_tier3 := Color(0.87, 0, 1)

@onready var e: BaseEnemy = owner
@onready var element_indicator: ElementIndicator = $HBoxContainer/element_indicator
@onready var debuff_indicator: DebuffIndicator = $HBoxContainer/debuff_indicator
@onready var healthbar: ProgressBar = $Healthbar
@onready var HBox: HBoxContainer = $HBoxContainer

func _ready() -> void:
	assert(damage_number, "forgot to export")

#region Health Component
func damage_received(damage: float, new_elem: CombatManager.Elements, ep: float = 0) -> void:
	var inflicted_reaction: CombatManager.Reactions = CombatManager.Reactions.NONE
	
	if element_initial == CombatManager.Elements.NONE:
		element_initial = new_elem
		element_indicator.element = new_elem
	elif new_elem != CombatManager.Elements.NONE && new_elem != element_initial:
		inflicted_reaction = apply_reaction(new_elem, ep)
		if inflicted_reaction == CombatManager.Reactions.MELT:
			damage = damage * (2 + ep/100)
	
	if damage > 0:
		spawn_dmg_number(str(round(damage)), CombatManager.params[new_elem])
	
	if e.health - damage > 0:
		e.health -= damage
		produce_energy(0.5)
	elif not is_dead:
		produce_energy(3)
		is_dead = true
		EventBus.enemy_died.emit(e)
		EnemyAiManager.spawn_orbs(global_position, e.mana_orbs_dropped)
		clear_debuff_references()
		SoundPlayer.play_sound_2D(global_position, enemy_explosion_sfx, explosion_volume + 7, 1.1)
		e.make_impact()
		e.queue_free()


func produce_energy(procs: float) -> void:
	EventBus.energy_gen_from_enemy_got_hit.emit(procs)


func spawn_dmg_number(effect: String, color: Color) -> void:
	var pos_variance: Vector2
	var label_inst: LabelCombatText = damage_number.instantiate()
	
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


func apply_reaction(new_elem: CombatManager.Elements, ep: float) -> CombatManager.Reactions:
	#print(CombatManager.Elements.keys()[element_initial] + " ||NEW: " 
	#+ CombatManager.Elements.keys()[new_elem])
	var reaction: CombatManager.Reactions = CombatManager.determine_reaction(element_initial, new_elem)
	match reaction:
		CombatManager.Reactions.MELT:
			spawn_dmg_number("Melt", CombatManager.params["melt"])
			## double damage dealt
		CombatManager.Reactions.SUPERCONDUCT:
			apply_debuff(CombatManager.Debuffs.SUPERCONDUCT, ep)
			spawn_dmg_number("Superconduct", CombatManager.params["superconduct"])
		CombatManager.Reactions.OVERLOAD:
			spawn_dmg_number("Overload", CombatManager.params["overload"])
			spawn_overload_impact(global_position, ep)
			## interrupt enemy charging attack (LASER, ORB)
				## enemy is interrupted by cancelling current fire cycle and
				## subtracting one ammo to force a reload
		_: ## NONE or other not yet implemented reactions
			pass
	element_initial = CombatManager.Elements.NONE
	element_indicator.element = CombatManager.Elements.NONE
	return reaction
#endregion


func spawn_overload_impact(pos: Vector2, ep: float) -> void:
	var inst: DamageImpact = CombatManager.overload_impact.instantiate()
	var base_dmg: float = 10
	var overload_dmg: float = base_dmg + (ep ** 1.2)
	inst.global_position = pos
	inst.damage = overload_dmg
	inst.element = CombatManager.Elements.NONE
	get_tree().root.call_deferred("add_child", inst)


#region Debuff Component
func apply_debuff(new_debuff: CombatManager.Debuffs, ep: float) -> void:
	match new_debuff:
		CombatManager.Debuffs.SUPERCONDUCT:
			if superconduct_effect:
				superconduct_effect.apply_effect(self, ep)
		CombatManager.Debuffs.CRYSTALIZED:
			if crystalize_effect:
				crystalize_effect.apply_effect(self, ep)
		_:
			pass
	debuff_indicator.current_debuff = new_debuff


func clear_debuff_references() -> void:
	if crystalize_effect:
		crystalize_effect.delete_ref(self)
	if superconduct_effect:
		superconduct_effect.delete_ref(self)
#endregion


func set_healthbar_properties(og_length: float) -> void: ## called by BaseEnemy.gd
	var size: float = clampf(og_length/3, 1, 100)
	
	healthbar.size.x = size
	healthbar.position.x = -size/2
	HBox.position.x = -size/2
	
	if og_length >= e.max_health: ## x1 HP
		healthbar.modulate = color_tier1
	elif og_length * 3 >= e.max_health: ## x3 HP
		healthbar.modulate = color_tier2
	else: ## more than x2 HP
		healthbar.modulate = color_tier3
