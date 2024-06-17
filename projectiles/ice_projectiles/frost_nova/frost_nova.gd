extends Marker2D
class_name FrostStorm
# an area effect tht spawns ice_spike_bullet_impact around it

@export var bullet_impact: PackedScene

@onready var t_spawn_cd: Timer = $spawn_cd

var radius: float = 60
var max_spawn_counter: int = 30
var spawn_counter: int = 0
var size: float = 1

var damage: float = 10
var debuff: CombatManager.Debuffs = CombatManager.Debuffs.NONE
var _time: float = 0 ## FOR TESTING
@onready var rng := RandomNumberGenerator.new()

func _ready() -> void:
	assert(bullet_impact, "missing")
	EventBus.clear_abilities.connect(queue_free)

func _physics_process(_delta: float) -> void:
	#_time += _delta
	if spawn_counter >= max_spawn_counter:
		#print("Time ended: %f" % _time)
		queue_free()

func _on_spawn_cd_timeout() -> void:
	spawn_impact(global_position + Vector2(rng.randf_range(-radius, radius), rng.randf_range(-radius, radius) ) )

func spawn_impact(pos: Vector2) -> void:
	var instance: DamageImpact = bullet_impact.instantiate()
	instance.global_position = pos
	instance.damage = damage
	instance.scale = Vector2(1, 1) * size
	instance.debuff = debuff
	get_tree().root.call_deferred("add_child", instance)
	spawn_counter += 1
