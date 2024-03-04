extends Node2D
class_name EnemyHealthComponent

@export var damage_number: PackedScene
@onready var e: BaseEnemy = owner

@onready var element_indicator: Sprite2D = $element_indicator

var rng := RandomNumberGenerator.new()

var element_initial: CombatManager.Elements = CombatManager.Elements.NONE

func _ready() -> void:
	assert(damage_number, "forgot to export")

func damage_received(damage: float, new_elem: CombatManager.Elements) -> void:
	if damage > 0:
		spawn_dmg_number(str(damage), Color(1, 1, 1))
	
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
	else:
		PlayerInfo.mana_orbs += e.max_health
		e.make_impact()
		e.queue_free()

func spawn_dmg_number(effect: String, color: Color) -> void:
	var pos_variance: Vector2 = Vector2(rng.randf_range(-7, 7),
		rng.randf_range(-7, 7) )
	var label_inst: Label = damage_number.instantiate()
	label_inst.global_position = self.global_position + pos_variance
	label_inst.text = effect
	label_inst.modulate = color
	label_inst.z_index = 1
	get_tree().root.call_deferred("add_child", label_inst)

func apply_reaction(new_elem: CombatManager.Elements) -> void:
	#print(CombatManager.Elements.keys()[element_initial] + " ||NEW: " 
	#+ CombatManager.Elements.keys()[new_elem])
	match element_initial:
		CombatManager.Elements.LIGHTNING:
			match new_elem:
				CombatManager.Elements.ICE:
					e.superconduct()
					spawn_dmg_number("Superconduct", Color(0.5, 0.5, 1))
				_:
					pass
		CombatManager.Elements.ICE:
			match new_elem:
				CombatManager.Elements.LIGHTNING:
					e.superconduct()
					spawn_dmg_number("Superconduct", Color(0.5, 0.5, 1))
				_:
					pass
		_:
			pass
	element_initial = CombatManager.Elements.NONE
	element_indicator.element = CombatManager.Elements.NONE
