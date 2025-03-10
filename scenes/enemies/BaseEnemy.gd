extends StaticBody2D
class_name BaseEnemy

signal health_changed(new_health: float)
signal reload_time_changed(new_reload_time: float)
signal attack_interrupted()

## these should probs be made more elegant
var _default_impact_scene: PackedScene = preload("res://projectiles/bullet_impact.tscn")
var _default_dead_texture: AtlasTexture = preload("res://resources/textures/impacts/enemy_dead.tres")

@export_category("Enemy Stats")
@export var stats: EnemyStats ## SET ENEMY STATS
@export var interruptable: bool = true
@export_category("Visuals")
# im recycling this for enemy's death explosion sfx
@export var bullet_impact_scene: PackedScene ## can be null
@export var enemy_dead_texture: AtlasTexture ## can be null
@export var impact_scale: Vector2 = Vector2(3, 3)

var damage_number: PackedScene = preload("res://user_interface/UI_attached_to_enemies/label_dmg_num.tscn")
var rng := RandomNumberGenerator.new()

# debuff vars:
#var debuff_by_superconduct: bool = false
## im against this ^ this "reload_time_changed" signal alrdy indicates it

var max_health: float = 50.0
var default_reload_time: float = 5.0
var mana_orbs_dropped: float

var HP_multiplier: float = 1 ## affected by area scaling during instantiation

var health: float = max_health:
	set(value):
		health = value
		health_changed.emit(health)
var reload_time: float = default_reload_time:
	set(value):
		reload_time = value
		reload_time_changed.emit(reload_time)
var default_color: Color
var spawned_runtime: bool = false ## for spawned enemies like Small Drone

## UI:
#var healthbar_length: float ## set by enemy holder on spawn
## now replaced by stats.health, since it has the initial HP before area scaling


# now combined health and debuff
@onready var health_component: EnemyHealthComponent = $HealthComponent
@onready var sprite_main: Sprite2D = $Sprite2D_main


func _ready() -> void:
	assert(stats, "missing enemy_stats on %s" % name)
	assert(health_component, "missing health comp")
	if not bullet_impact_scene:
		bullet_impact_scene = _default_impact_scene
	if not enemy_dead_texture:
		enemy_dead_texture = _default_dead_texture
	
	_set_stats()
	health = max_health
	reload_time = default_reload_time
	EnemyAiManager.enemies_alive += 1
	
	default_color = sprite_main.modulate
	if not spawned_runtime:
		process_mode = Node.PROCESS_MODE_DISABLED
		await get_tree().create_timer(0.5).timeout
		process_mode = Node.PROCESS_MODE_INHERIT

## called by HealthComponent
func take_damage(damage: float, element: CombatManager.Elements, ep: float = 0) -> void:
	if health_component:
		health_component.raw_damage_received(damage, element, ep)

## called by HealthComponent
func take_debuff(debuff: CombatManager.Debuffs, ep: float = 0) -> void:
	if health_component:
		health_component.apply_debuff(debuff, ep)

## called by HealthComponent
func try_attack_interrupted() -> void:
	if interruptable:
		attack_interrupted.emit()

## called by HealthComponent
func make_impact() -> void:
	var imp_instance: BulletImpact = bullet_impact_scene.instantiate()
	imp_instance.global_position = global_position
	imp_instance.texture = enemy_dead_texture
	imp_instance.transparency = 0.5
	imp_instance.decay_rate = 5
	imp_instance.scale = impact_scale
	get_tree().root.call_deferred("add_child",imp_instance)


func _set_stats() -> void:
	max_health = stats.health * HP_multiplier
	default_reload_time = stats.default_reload_time


func spawn_dmg_number(effect: String, color: Color) -> void:
	var pos_variance: Vector2
	var label_inst: LabelCombatText = damage_number.instantiate()
	
	label_inst.text = effect
	label_inst.modulate = color
	
	if effect.is_valid_int():
		pos_variance = Vector2(rng.randf_range(-10, 10), rng.randf_range(-5, 5) )
	else:
		label_inst.speed = -20
		label_inst.duration = 1.2
		if effect == "Superconduct": ## HEALTH COMPONENT is for these effects
			pos_variance = Vector2(-33,-20)
		elif effect == "Melt":
			pos_variance = Vector2(-11,-20)
		elif effect == "Overload":
			pos_variance = Vector2(-21.5,-20)
		elif effect == "INTERRUPTED!": ## ATTACK COMPONENT DOES THIS!!!
			pos_variance = Vector2(-35,20)
			label_inst.speed = 0
		else:
			pos_variance = Vector2(-37,-20)
	
	label_inst.global_position = self.global_position + pos_variance
	get_tree().root.call_deferred("add_child", label_inst)
