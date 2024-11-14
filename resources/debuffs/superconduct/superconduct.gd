extends Resource
class_name Superconduct

@export_category("Debuff Effects") ## only when i add a 2nd superconduct against boses
var duration: float = 7
var base_dmg: float = 15

@export_category("Particles")
@export var particles_process_mat: ParticleProcessMaterial
@export var particles_textures: AtlasTexture
@export var one_shot: bool = true
@export var amount: int = 30
@export var explosiveness: float = 1
@export var lifetime: float = 0.7

var e_health: EnemyHealthComponent
var _debuff_timer: Timer
var color_sc: Color = Color(0.8, 0.5, 1)

var sprite_tween: Tween


func apply_effect(HealthComp: EnemyHealthComponent, ep: float) -> void:
	if not e_health:
		e_health = HealthComp
		_debuff_timer = Timer.new()
		_debuff_timer.one_shot = true
		_debuff_timer.autostart = false
		_debuff_timer.wait_time = duration
		_debuff_timer.timeout.connect(superconduct_ended.bind(HealthComp.e))
		HealthComp.add_child(_debuff_timer) 
		## wtf i just realized i add a timer, but this works since it only adds it once
	
	if e_health:
		var enemy_node: BaseEnemy = e_health.e
		receive_superconduct(enemy_node, ep)
		_debuff_timer.start()


func receive_superconduct(enemy: BaseEnemy, ep: float) -> void:
	ParticlesQueueNode.set_property_restart(particles_process_mat,
			particles_textures,
			one_shot,
			amount,
			explosiveness,
			lifetime,
			enemy.global_position,)
	var final_dmg: float = damage_equation(ep)
	enemy.take_damage(final_dmg, CombatManager.Elements.NONE)
	enemy.reload_time = enemy.default_reload_time + 1
	
	sprite_tween = enemy.create_tween()
	sprite_tween.tween_property(enemy.sprite_main, "modulate", 
			enemy.default_color, duration).from(color_sc)


func damage_equation(ep: float) -> float:
	var ep_dmg: float = ep * 1.25
	return base_dmg + ep_dmg


func superconduct_ended(enemy: BaseEnemy) -> void:
	if sprite_tween:
		sprite_tween.kill()
		#print_debug("tween running: ", sprite_tween.is_running())
		sprite_tween = null
	enemy.reload_time = enemy.default_reload_time
	enemy.sprite_main.modulate = enemy.default_color


func clear() -> void:
	if e_health:
		superconduct_ended(e_health.e)
	if _debuff_timer:
		_debuff_timer.stop()
