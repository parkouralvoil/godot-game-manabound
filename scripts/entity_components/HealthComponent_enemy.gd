extends Node2D
class_name EnemyHealthComponent

@export var damage_number: PackedScene
@onready var e: BaseEnemy = owner

@onready var element_indicator: ElementIndicator = $HBoxContainer/element_indicator
@onready var debuff_indicator: DebuffIndicator = $HBoxContainer/debuff_indicator
@onready var healthbar: ProgressBar = $Healthbar
@onready var HBox: HBoxContainer = $HBoxContainer

var rng := RandomNumberGenerator.new()

var element_initial: CombatManager.Elements = CombatManager.Elements.NONE

var is_dead: bool = false

func _ready() -> void:
	var healthbar_size: float = 5.0 + (10.0 * (e.max_health/20.0) )
	healthbar.size.x = healthbar_size
	healthbar.position.x = -healthbar_size/2
	HBox.position.x = -healthbar_size/2
	
	assert(damage_number, "forgot to export")

#region Health Component
func damage_received(damage: float, new_elem: CombatManager.Elements) -> void:
	if damage > 0:
		spawn_dmg_number(str(round(damage)), CombatManager.params[new_elem])
	
	if e.health - damage > 0:
		e.health -= damage
		match element_initial:
			CombatManager.Elements.NONE:
				element_initial = new_elem
			#spawn_dmg_number(CombatManager.Elements.keys()[new_elem])
				element_indicator.element = new_elem
			_:
				if new_elem != CombatManager.Elements.NONE && new_elem != element_initial:
					apply_reaction(new_elem)
	elif not is_dead:
		is_dead = true
		PlayerInfo.mana_orbs += int(e.max_health)
		EventBus.enemy_died.emit()
		e.make_impact()
		e.queue_free()

func spawn_dmg_number(effect: String, color: Color) -> void:
	var pos_variance: Vector2
	var label_inst: Label = damage_number.instantiate()
	
	if effect.is_valid_int():
		pos_variance = Vector2(rng.randf_range(-10, 10), rng.randf_range(-5, 5) )
	else:
		pos_variance = Vector2(-30,-20)
		label_inst.speed = -20
	
	label_inst.global_position = self.global_position + pos_variance
	label_inst.text = effect
	label_inst.modulate = color
	get_tree().root.call_deferred("add_child", label_inst)

func apply_reaction(new_elem: CombatManager.Elements) -> void:
	#print(CombatManager.Elements.keys()[element_initial] + " ||NEW: " 
	#+ CombatManager.Elements.keys()[new_elem])
	match element_initial:
		CombatManager.Elements.LIGHTNING:
			match new_elem:
				CombatManager.Elements.ICE:
					apply_debuff(CombatManager.Debuffs.SUPERCONDUCT)
					spawn_dmg_number("Superconduct", CombatManager.params["superconduct"])
				_:
					pass
		CombatManager.Elements.ICE:
			match new_elem:
				CombatManager.Elements.LIGHTNING:
					apply_debuff(CombatManager.Debuffs.SUPERCONDUCT)
					spawn_dmg_number("Superconduct", CombatManager.params["superconduct"])
				_:
					pass
		_:
			pass
	element_initial = CombatManager.Elements.NONE
	element_indicator.element = CombatManager.Elements.NONE
#endregion

#region Debuff Component
#@onready var particle_Q: ParticleQueue = $particle_queue

@export var crystalize_effect: Crystalized
@export var superconduct_effect: Superconduct

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
#endregion
