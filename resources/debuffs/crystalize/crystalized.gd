extends Resource
class_name Crystalized

@export_category("Debuff Effects")
@export var duration: float = 1.5

@export_category("Particles")
@export var particles_process_mat: ParticleProcessMaterial
@export var particles_textures: AtlasTexture
@export var one_shot: bool = true
@export var amount: int = 1
@export var explosiveness: float = 0.6
@export var lifetime: float = 0.6

var e_health: EnemyHealthComponent = null
var crystal_stacks: int = 0
var accumulated_dmg: float = 0
var _debuff_timer: Timer

#var _scale_damage: float = 0.2 # PERCENTAGE!!
var _stack_detonate: int = 9

func apply_effect(HealthComp: EnemyHealthComponent, ep: float) -> void:
	if not e_health:
		e_health = HealthComp
		crystal_stacks = 0
		_debuff_timer = Timer.new()
		_debuff_timer.one_shot = true
		_debuff_timer.autostart = false
		_debuff_timer.wait_time = duration
		_debuff_timer.timeout.connect(detonate_crystalize)
		e_health.add_child(_debuff_timer)
	
	if e_health:
		crystal_stacks += 1
		accumulated_dmg += ep
		if _debuff_timer.is_stopped():
			_debuff_timer.start()
		if crystal_stacks >= _stack_detonate:
			detonate_crystalize()


func detonate_crystalize() -> void:
	if not e_health:
		return
	
	_debuff_timer.stop()
	
	var final_dmg: float = damage_equation()
	ParticlesQueueNode.set_property_restart(particles_process_mat,
			particles_textures,
			one_shot,
			amount * max(crystal_stacks, 1),
			explosiveness,
			lifetime,
			e_health.global_position,)
	
	var text: String = "Crystalize x" + str(crystal_stacks)
	var color: Color = CombatManager.params[CombatManager.Elements.ICE]
	e_health.spawn_dmg_number(text, color)
	
	if e_health:
		crystal_stacks = 0
		accumulated_dmg = 0
		e_health.raw_damage_received(final_dmg, CombatManager.Elements.NONE)


func damage_equation() -> float:
	var base_dmg: float = accumulated_dmg/3
	@warning_ignore("integer_division")
	var dmg_multiplier: float = 1 + 0.25 * int(crystal_stacks/3)
	## accumulated_dmg = value of EP for stack
	## final dmg = base * 1.5 at 9 stacks
	return base_dmg * max(1, dmg_multiplier)


func clear() -> void: ## clear is used if enemy can "respawn" itself (ie sideparts reconstruction)
	crystal_stacks = 0
	accumulated_dmg = 0
	if _debuff_timer:
		print_debug("TARGET:::::::::::")
		print_debug(_debuff_timer.is_stopped())
		_debuff_timer.stop()
		print_debug(_debuff_timer.is_stopped())
