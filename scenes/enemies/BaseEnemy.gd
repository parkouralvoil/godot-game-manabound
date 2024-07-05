extends CharacterBody2D
class_name BaseEnemy

@export var bullet_impact_scene: PackedScene # im recycling this for enemy's death explosion sfx
@export var enemy_dead_texture: AtlasTexture
@onready var health_component: EnemyHealthComponent = $HealthComponent # now combined health and debuff

@export var impact_scale: Vector2 = Vector2(3, 3)

@onready var sprite_main: Sprite2D = $Sprite2D_main

signal health_changed(new_health: float)
signal reload_time_changed(new_reload_time: float)

# debuff vars:
#var debuff_by_superconduct: bool = false
## im against this ^ this "reload_time_changed" signal alrdy indicates it
## draining ammo will be overload's effect

@export var max_health: float = 50.0
var health: float = max_health :
	set(value):
		health = value
		health_changed.emit(health)

@export var default_reload_time: float = 5.0
var reload_time: float = default_reload_time :
	set(value):
		reload_time = value
		reload_time_changed.emit(reload_time)


var default_color: Color
var spawned_runtime: bool = false ## for spawned enemies like Small Drone


func _ready() -> void:
	assert(health_component, "missing")
	health = max_health
	reload_time = default_reload_time
	assert(bullet_impact_scene, "missing ref")
	assert(enemy_dead_texture, "missing ref")
	EnemyAiManager.enemies_alive += 1
	
	default_color = sprite_main.modulate
	if not spawned_runtime:
		process_mode = Node.PROCESS_MODE_DISABLED
		await get_tree().create_timer(0.5).timeout
		process_mode = Node.PROCESS_MODE_INHERIT


func take_damage(damage: float, element: CombatManager.Elements) -> void:
	if health_component:
		health_component.damage_received(damage, element)


func take_debuff(debuff: CombatManager.Debuffs) -> void:
	if health_component:
		health_component.apply_debuff(debuff)


func make_impact() -> void:
	var imp_instance: BulletImpact = bullet_impact_scene.instantiate()
	imp_instance.global_position = global_position
	imp_instance.texture = enemy_dead_texture
	imp_instance.transparency = 0.5
	imp_instance.decay_rate = 5
	imp_instance.scale = impact_scale
	get_tree().root.call_deferred("add_child",imp_instance)
