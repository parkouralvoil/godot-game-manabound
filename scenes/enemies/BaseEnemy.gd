extends CharacterBody2D
class_name BaseEnemy

@export var bullet_impact_scene: PackedScene # im recycling this for enemy's death explosion sfx
@export var enemy_dead_texture: AtlasTexture
@onready var health_component: EnemyHealthComponent = $HealthComponent# manages elements/damage procs
@onready var debuff_component: EnemyDebuffComponent = $DebuffComponent # manages debuffs received

@export var impact_scale: Vector2 = Vector2(3, 3)

@onready var sprite_main: Sprite2D = $Sprite2D_main

signal health_changed(new_health: float)

@export var max_health: float = 50.0
var health: float = max_health :
	set(value):
		health = _on_health_change(value)
	get:
		return health

@export var default_reload_time: float = 5.0
var reload_time: float = default_reload_time :
	set(value):
		reload_time = value
	get:
		return reload_time

var bullet_color: Color = Color(1, 0.4, 0)

func _on_health_change(new_health: float) -> float:
	emit_signal("health_changed", new_health)
	return new_health

func _ready() -> void:
	assert(debuff_component, "missing")
	assert(health_component, "missing")
	health = max_health
	reload_time = default_reload_time
	assert(bullet_impact_scene, "missing ref")
	assert(enemy_dead_texture, "missing ref")
	
	# to give leeway for char when they first enter
	process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(2).timeout
	process_mode = Node.PROCESS_MODE_INHERIT

func take_damage(damage: float, element: CombatManager.Elements) -> void:
	if health_component:
		health_component.damage_received(damage, element)

func make_impact() -> void:
	var imp_instance: BulletImpact = bullet_impact_scene.instantiate()
	imp_instance.global_position = global_position
	imp_instance.texture = enemy_dead_texture
	imp_instance.decay_rate = 10
	imp_instance.scale = impact_scale
	get_tree().root.call_deferred("add_child",imp_instance)

func superconduct() -> void:
	debuff_component.receive_superconduct()
