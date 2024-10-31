extends Node2D
class_name EnemyHealthComponent

@export var enemy_explosion_sfx: AudioStream
@export var explosion_volume: float = -15

@export_category("Debuff Resources")
@export var crystalize_effect: Crystalized
@export var superconduct_effect: Superconduct
## OVERLOAD and MELT are builtin for now, 
	## but once i add ways to change reaction effects
	## they need to be relagated to debuff resources

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

## damage number moved to baseEnemy, since atk component needs it too
#func _ready() -> void:
	#assert(damage_number, "forgot to export") 

#region Health Component
func damage_received(damage: float, new_elem: CombatManager.Elements, ep: float = 0) -> void:
	var inflicted_reaction: CombatManager.Reactions = CombatManager.Reactions.NONE
	
	#print_debug("received ep = %0.1f" % ep)
	
	if element_initial == CombatManager.Elements.NONE:
		element_initial = new_elem
		element_indicator.element = new_elem
	elif new_elem != CombatManager.Elements.NONE && new_elem != element_initial:
		inflicted_reaction = apply_reaction(new_elem, ep)
		if inflicted_reaction == CombatManager.Reactions.MELT:
			damage = damage * (2 + ep/100)
	
	if damage > 0:
		e.spawn_dmg_number(str(round(damage)), CombatManager.params[new_elem])
	
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

## required for dev_console's skip_dungeon_level()
func _notification(what: int) -> void:
	if(what == NOTIFICATION_PREDELETE):
		if not is_dead: ## not dead, since enemyholder would handle it
			BaseEnemy.enemies_alive -= 1


func produce_energy(procs: float) -> void:
	EventBus.energy_gen_from_enemy_got_hit.emit(procs)


func apply_reaction(new_elem: CombatManager.Elements, ep: float) -> CombatManager.Reactions:
	#print(CombatManager.Elements.keys()[element_initial] + " ||NEW: " 
	#+ CombatManager.Elements.keys()[new_elem])
	var reaction: CombatManager.Reactions = CombatManager.determine_reaction(element_initial, new_elem)
	match reaction:
		CombatManager.Reactions.MELT:
			e.spawn_dmg_number("Melt", CombatManager.params["melt"])
			## double damage dealt
		CombatManager.Reactions.SUPERCONDUCT:
			apply_debuff(CombatManager.Debuffs.SUPERCONDUCT, ep)
			e.spawn_dmg_number("Superconduct", CombatManager.params["superconduct"])
		CombatManager.Reactions.OVERLOAD:
			e.spawn_dmg_number("Overload", CombatManager.params["overload"])
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
	var base_dmg: float = 20
	var ep_dmg: float = ep * 1.5
	var overload_dmg: float = base_dmg + ep_dmg
	
	e.try_attack_interrupted()
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
	var size: float = clampf(og_length/4.5, 5, 100)
	
	healthbar.size.x = size
	healthbar.position.x = -size/2
	HBox.position.x = -size/2
	
	if og_length >= e.max_health: ## x1 HP
		healthbar.modulate = color_tier1
	elif og_length * 3 >= e.max_health: ## x3 HP
		healthbar.modulate = color_tier2
	else: ## more than x2 HP
		healthbar.modulate = color_tier3
