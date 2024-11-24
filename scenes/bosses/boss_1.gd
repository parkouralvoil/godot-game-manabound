extends Node2D
class_name RailgunBoss ## this is not an enemy, its more of a boss holder / enemy holder

enum PHASE {
	ONE,
	TWO,
}

## no more phase 2, ill save it for "willpower bosses"
## machine/structure bosses strictly follow their programming
@export var Phase1_HP: float = 4000 ## will update stats.HP of main gun to have this

var _default_impact_scene: PackedScene = preload("res://projectiles/bullet_impact.tscn")
var _default_dead_texture: AtlasTexture = preload("res://resources/textures/impacts/enemy_dead.tres")

#var current_phase: PHASE = PHASE.ONE
var boss_HP_bar: ProgressBar:
	set(val):
		boss_HP_bar = val
		if val:
			boss_HP_bar.value = boss_HP_bar.max_value
var boss_box: Container
var boss_dead: bool = false

var move_key: int = 2
var movement: Dictionary = { ## 2 > 3 > 4 > 5 > 1 > 2
	1: Vector2(373, -373), # center
	2: Vector2(214, -482), # top left
	3: Vector2(560, -482), # top right
	4: Vector2(214, -188), # bot left
	5: Vector2(560, -188), # bot right
}
var movement_tween: Tween = null
@onready var next_pos: Vector2 = global_position

@onready var current_MAX_HP: float = Phase1_HP
@onready var current_HP: float = Phase1_HP:
	set(val):
		current_HP = val
		update_healthbar()
#@onready var main_boss_hurtbox: HurtboxComponent = $MainGun/BossHurtbox
@onready var main_gun: RailgunMainGun = $MainGun
@onready var main_boss_health_comp: MainRailgun_Health = $MainGun/HealthComponent
@onready var laser_left: SidepartRailgun = $LaserLeft
@onready var laser_right: SidepartRailgun = $LaserRight
@onready var orb_top: SidepartRailgun = $OrbTop
@onready var orb_bot: SidepartRailgun = $OrbBot
@onready var components: Array[SidepartRailgun] = [laser_left, laser_right, orb_top, orb_bot]
@onready var death_particles: GPUParticles2D = $DeathParticles


func _ready() -> void:
	const time_before_bossfight_starts: float = 2.5
	const move_duration: float = 3
	
	main_gun.phase1_attack_done.connect(_phase1_movement)
	await get_tree().create_timer(time_before_bossfight_starts).timeout
	
	if movement_tween and movement_tween.is_running():
		movement_tween.kill()
	movement_tween = create_tween()
	movement_tween.tween_property(self, "position", movement[1], move_duration)
	await movement_tween.finished
	await get_tree().create_timer(0.8).timeout
	
	_initialize_phase_one()

func _initialize_phase_one() -> void:
	EventBus.boss_fight_started.emit(self)
	assert(boss_box, "fix boss box passing")
	main_boss_health_comp.initialize_main_health_comp(boss_box)
	main_boss_health_comp.main_part_damaged.connect(take_boss_damage)
	_disable_invulnerability()
	_activate_attack_components()
	## start music


func _disable_invulnerability() -> void:
	main_gun.invulnerable = false
	for c in components:
		c.invulnerable = false


func _activate_attack_components() -> void:
	main_gun.fight_started = true
	for c in components:
		c.fight_started = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func take_boss_damage(damage: float) -> void:
	current_HP = max(current_HP - damage, 0)
	if current_HP <= 0 and not boss_dead:
		_destroy_boss()
		boss_dead = true


func update_healthbar() -> void:
	if boss_HP_bar:
		boss_HP_bar.value = (current_HP/current_MAX_HP) * boss_HP_bar.max_value


func _phase1_movement() -> void:
	if (position - movement[1]).length_squared() >= 15: ## go to center
		next_pos = movement[1]
		if move_key > 5:
			move_key = 2
	else: ## go to corner
		next_pos = movement[move_key]
		move_key += 1
	await get_tree().create_timer(0.8).timeout
	if boss_dead:
		return
	movement_tween = create_tween()
	movement_tween.tween_property(self, "position", next_pos, 2.2)

func make_impact(impact_scene: PackedScene, offset: Vector2, scale_multiplier: float) -> void:
	var imp_instance: BulletImpact = impact_scene.instantiate()
	imp_instance.global_position = global_position + offset
	imp_instance.texture = _default_dead_texture
	imp_instance.transparency = 0.5
	imp_instance.decay_rate = 5
	imp_instance.scale = imp_instance.scale * scale_multiplier
	get_tree().root.call_deferred("add_child", imp_instance)


func _destroy_boss() -> void:
	if movement_tween:
		movement_tween.kill()
	
	death_particles.emitting = true
	main_gun.boss_defeated()
	for c in components:
		c.boss_defeated()
	
	var explosion_times: int = 15
	var orbs_dropped: int = 4000/explosion_times
	for i in range(explosion_times):
		var offset := Vector2(1, 1) * RNG.random_float(-25, 25)
		var size_int := RNG.random_float(3, 8)
		make_impact(_default_impact_scene, offset, size_int)
		main_gun.show_hit_flash()
		EnemyAiManager.spawn_orbs(global_position, orbs_dropped)
		await get_tree().create_timer(0.15).timeout
	await get_tree().create_timer(0.5).timeout
	make_impact(_default_impact_scene, Vector2.ZERO, 15)
	EventBus.boss_fight_ended.emit()
	queue_free()
	
	## end the expedition (success) after player goes thru door
