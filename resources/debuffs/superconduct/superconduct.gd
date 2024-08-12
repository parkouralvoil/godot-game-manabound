extends Resource
class_name Superconduct

@export_category("Debuff Effects") ## only when i add a 2nd superconduct against boses
var duration: float = 7
var base_dmg: float = 5

@export_category("Particles")
@export var particles_process_mat: ParticleProcessMaterial
@export var particles_textures: AtlasTexture
@export var one_shot: bool = true
@export var amount: int = 30
@export var explosiveness: float = 1
@export var lifetime: float = 0.7

class EnemyInfo:
	var timer: Timer

var enemy_ref: Dictionary = {}
var color_sc: Color = Color(0.8, 0.5, 1)

func get_info(_enemy_HealthComp: EnemyHealthComponent) -> int:
	return 0


func apply_effect(HealthComp: EnemyHealthComponent, ep: float) -> void:
	if not enemy_ref.has(HealthComp):
		var info: EnemyInfo = EnemyInfo.new()
		info.timer = Timer.new()
		info.timer.one_shot = true
		info.timer.autostart = false
		info.timer.wait_time = duration
		info.timer.timeout.connect(superconduct_ended.bind(HealthComp.e))
		HealthComp.add_child(info.timer) ## wtf i just realized i add a timer, but this works since it only adds it once
		enemy_ref[HealthComp] = info ## and the timer gets cleared when the enemy dies (gets freed)
	
	if enemy_ref.has(HealthComp):
		var current_e: EnemyInfo = enemy_ref[HealthComp]
		receive_superconduct(HealthComp.e, ep)
		current_e.timer.start()


func receive_superconduct(enemy: BaseEnemy, ep: float) -> void:
	var tween: Tween = enemy.create_tween()
	ParticlesQueueNode.set_property_restart(particles_process_mat,
			particles_textures,
			one_shot,
			amount,
			explosiveness,
			lifetime,
			enemy.global_position,)
	var dmg_proc: float = (ep ** 1.1) + base_dmg
	enemy.take_damage(dmg_proc, CombatManager.Elements.NONE)
	enemy.reload_time = enemy.default_reload_time + 1
	
	tween.tween_property(enemy.sprite_main, "modulate", 
			enemy.default_color, duration).from(color_sc)


func superconduct_ended(enemy: BaseEnemy) -> void:
	enemy.reload_time = enemy.default_reload_time
	enemy.sprite_main.modulate = enemy.default_color


func delete_ref(HealthComp: EnemyHealthComponent) -> void:
	enemy_ref.erase(HealthComp)
