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

class EnemyInfo:
	var crystal_stacks: int = 0
	var accumulated_dmg: float = 0
	var timer: Timer

var scale_damage: float = 0.2 # PERCENTAGE!!
var stack_detonate: int = 9

var enemy_ref: Dictionary = {}

func get_info(HealthComp: EnemyHealthComponent) -> int:
	if enemy_ref.has(HealthComp):
		return enemy_ref[HealthComp].crystal_stacks
	else:
		return 0


func apply_effect(HealthComp: EnemyHealthComponent, ep: float) -> void:
	if not enemy_ref.has(HealthComp):
		var info: EnemyInfo = EnemyInfo.new()
		info.crystal_stacks = 0
		info.timer = Timer.new()
		info.timer.one_shot = true
		info.timer.autostart = false
		info.timer.wait_time = duration
		info.timer.timeout.connect(detonate_crystalize.bind(HealthComp))
		HealthComp.add_child(info.timer)
		enemy_ref[HealthComp] = info
	
	if enemy_ref.has(HealthComp):
		var current_e: EnemyInfo = enemy_ref[HealthComp]
		current_e.crystal_stacks += 1
		current_e.accumulated_dmg += ep
		if current_e.timer.is_stopped():
			current_e.timer.start()
		if enemy_ref[HealthComp].crystal_stacks >= stack_detonate:
			detonate_crystalize(HealthComp)


func detonate_crystalize(HealthComp: EnemyHealthComponent) -> void:
	if not HealthComp:
		enemy_ref.erase(HealthComp)
		return
	
	enemy_ref[HealthComp].timer.stop()
	
	var final_dmg: float = damage_equation(enemy_ref[HealthComp])
	ParticlesQueueNode.set_property_restart(particles_process_mat,
			particles_textures,
			one_shot,
			amount * max(enemy_ref[HealthComp].crystal_stacks, 1),
			explosiveness,
			lifetime,
			HealthComp.global_position,)
	if enemy_ref.has(HealthComp):
		enemy_ref[HealthComp].crystal_stacks = 0
		enemy_ref[HealthComp].accumulated_dmg = 0
	
	var text: String = "Crystalize x" + str(enemy_ref[HealthComp].crystal_stacks)
	HealthComp.spawn_dmg_number(text, CombatManager.params[CombatManager.Elements.ICE])
	HealthComp.debuff_indicator.current_debuff = CombatManager.Debuffs.NONE
	
	HealthComp.damage_received(final_dmg, CombatManager.Elements.NONE)

func delete_ref(HealthComp: EnemyHealthComponent) -> void:
	enemy_ref.erase(HealthComp)


func damage_equation(crystalized_info: EnemyInfo) -> float:
	var stacks: int = crystalized_info.crystal_stacks
	var base_dmg: float = crystalized_info.accumulated_dmg/3
	
	@warning_ignore("integer_division")
	var dmg_multiplier: float = 1 + 0.25 * int(stacks/3)
	
	## accumulated_dmg = value of EP for stack
	## final dmg = base * 1.5 at 9 stacks
	
	return base_dmg * max(1, dmg_multiplier)
	
	
