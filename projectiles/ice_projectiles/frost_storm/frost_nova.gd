extends Marker2D
class_name FrostStorm
# an area effect tht spawns ice_spike_bullet_impact around it

@export var bullet_impact: PackedScene

@onready var t_spawn_cd: Timer = $spawn_cd
@onready var crystal: Sprite2D = $Sprite2D_crystal
#@onready var circle: Sprite2D = $Sprite2D_circle
@onready var rng := RandomNumberGenerator.new()

var ep: float = 0
var radius: float = 60
var max_spawn_counter: int = 30
var spawn_counter: int = 0
var size: float = 1

var damage: float = 10
var debuff: CombatManager.Debuffs = CombatManager.Debuffs.NONE

var despawn_set: bool = false
var rotation_speed: float = 2

func _ready() -> void:
	assert(bullet_impact, "missing")
	rotation_speed += float(max_spawn_counter/30.0)
	crystal.scale = crystal.scale * size
	EventBus.clear_abilities.connect(queue_free)


func _physics_process(_delta: float) -> void:
	#_time += _delta
	crystal.rotate(rotation_speed * _delta)
	if spawn_counter >= max_spawn_counter and not despawn_set:
		#print("Time ended: %f" % _time)
		despawn_set = true
		var t := create_tween()
		t.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.7)
		await t.finished
		queue_free()


func _on_spawn_cd_timeout() -> void:
	spawn_impact(global_position + Vector2(rng.randf_range(-radius, radius), rng.randf_range(-radius, radius) ) )


func spawn_impact(pos: Vector2) -> void:
	var instance: DamageImpact = bullet_impact.instantiate()
	instance.global_position = pos
	instance.damage = damage
	instance.scale = Vector2(1, 1) * size
	instance.debuff = debuff
	instance.ep = ep
	get_tree().root.call_deferred("add_child", instance)
	spawn_counter += 1
