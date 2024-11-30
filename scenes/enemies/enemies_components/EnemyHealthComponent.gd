extends Node2D
class_name EnemyHealthComponent

@export_category("Visuals")
@export var enemy_explosion_sfx: AudioStream
@export var explosion_volume: float = -15

@export_category("Debuff Effects")
@export var crystalize_effect: Crystalized
@export var superconduct_effect: Superconduct
var overload_sfx: AudioStream = preload("res://assets/audio/sfx/EM_FIRE_CAST_01.mp3")
## OVERLOAD and MELT are builtin for now, 
	## but once i add ways to change reaction effects
	## they need to be relagated to debuff resources

var element_initial: CombatManager.Elements = CombatManager.Elements.NONE
var is_dead: bool = false

@onready var e: BaseEnemy = get_parent()
@onready var box: Container
@onready var element_indicator: ElementIndicator
@onready var debuff_indicator: DebuffIndicator

func _ready() -> void:
	assert(box, "fix ready function of health comp to assign box for indicators: %s" % e.name)
	element_indicator = box.get_node("element_indicator")
	debuff_indicator = box.get_node("debuff_indicator")
	
	assert(enemy_explosion_sfx, "missing sfx export: %s" % e.name)
	assert(crystalize_effect, "missing crystalize export: %s" % e.name)
	assert(superconduct_effect, "missing superconduct export: %s" % e.name)

#region Health Component
func raw_damage_received(damage: float, new_elem: CombatManager.Elements, ep: float = 0) -> void:
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
		spawn_dmg_number(str(round(damage)), CombatManager.params[new_elem])
	_final_damage_received(damage)
	call_deferred("update_debuff_indicator")


func _final_damage_received(final_dmg: float) -> void:
	if e.health - final_dmg > 0:
		e.health -= final_dmg
		produce_energy(0.5)
	elif not is_dead:
		produce_energy(3)
		is_dead = true
		EventBus.enemy_died.emit(e)
		EnemyAiManager.spawn_orbs(global_position, e.mana_orbs_dropped)
		SoundPlayer.play_sound_2D(global_position, enemy_explosion_sfx, explosion_volume + 7, 1.1)
		e.make_impact()
		e.queue_free()


func spawn_dmg_number(text: String, color: Color) -> void: ## interface
	e.spawn_dmg_number(text, color)


## required for dev_console's skip_dungeon_level()
func _notification(what: int) -> void: ## THIS IS A BUILTIN FUNCTION?!?!?
	if(what == NOTIFICATION_PREDELETE):
		if not is_dead: ## not dead, since enemyholder would handle it
			EnemyAiManager.enemies_alive -= 1


func produce_energy(procs: float) -> void:
	EventBus.energy_gen_from_enemy_got_hit.emit(procs)


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
	
	SoundPlayer.play_sound_2D(global_position, overload_sfx, -9, 1.2)
	e.try_attack_interrupted()
	inst.global_position = pos
	inst.damage = overload_dmg
	inst.element = CombatManager.Elements.NONE
	get_tree().root.call_deferred("add_child", inst)


func apply_debuff(new_debuff: CombatManager.Debuffs, ep: float) -> void:
	match new_debuff:
		CombatManager.Debuffs.SUPERCONDUCT:
			if superconduct_effect:
				superconduct_effect.apply_effect(self, ep)
			debuff_indicator.notify_debuff(new_debuff)
		CombatManager.Debuffs.CRYSTALIZED:
			var count: int = crystalize_effect.crystal_stacks
			if crystalize_effect:
				crystalize_effect.apply_effect(self, ep)
			debuff_indicator.notify_debuff(new_debuff, count)
		_:
			pass


func update_debuff_indicator() -> void:
	var count: int = crystalize_effect.crystal_stacks
	debuff_indicator.notify_debuff(CombatManager.Debuffs.CRYSTALIZED, count)
