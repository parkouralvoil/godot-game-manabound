extends Resource
class_name Superconduct

@export_category("Debuff Effects")
@export var duration: float = 7

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


func apply_effect(HealthComp: EnemyHealthComponent) -> void:
	if not enemy_ref.has(HealthComp):
		var info: EnemyInfo = EnemyInfo.new()
		info.timer = Timer.new()
		info.timer.one_shot = true
		info.timer.autostart = false
		info.timer.wait_time = duration
		info.timer.timeout.connect(superconduct_ended.bind(HealthComp))
		HealthComp.add_child(info.timer)
		enemy_ref[HealthComp] = info
	
	if enemy_ref.has(HealthComp):
		var current_e: EnemyInfo = enemy_ref[HealthComp]
		receive_superconduct(HealthComp)
		current_e.timer.start()


func receive_superconduct(HealthComp: EnemyHealthComponent) -> void:
	var tween: Tween = HealthComp.create_tween()
	var enemy: BaseEnemy = HealthComp.e
	ParticlesQueueNode.set_property_restart(particles_process_mat,
			particles_textures,
			one_shot,
			amount,
			explosiveness,
			lifetime,
			HealthComp.global_position,)
	enemy.take_damage(10, CombatManager.Elements.NONE)
	enemy.reload_time = (enemy.default_reload_time * 2) + 0.7
	
	tween.tween_property(enemy.sprite_main, "modulate", 
			enemy.default_color, duration).from(color_sc)


func superconduct_ended(HealthComp: EnemyHealthComponent) -> void:
	var enemy: BaseEnemy = HealthComp.e
	enemy.reload_time = enemy.default_reload_time
	enemy.sprite_main.modulate = enemy.default_color
