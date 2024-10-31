extends Node2D
class_name OrbExplosionSpawn

const orb_explosion_scene: PackedScene = preload("res://projectiles/enemy_projectiles/orb_explosion/orb_explosion.tscn")

@onready var blue_circle: Sprite2D = $blue_circle
@onready var red_circle: Sprite2D = $red_circle

var final_scale: Vector2 = Vector2(0.15, 0.15)
var time_before_explosion: float = 2
var attack_done: bool = true
var interrupted: bool = false

func prepare_impact(initial_pos: Vector2) -> void:
	global_position = initial_pos
	attack_done = false
	show()
	var tween: Tween = create_tween()
	tween.tween_property(red_circle, "scale", final_scale, 
			time_before_explosion).from(Vector2.ZERO)
	await tween.finished
	_attempt_fire()


func interrupt_impact() -> void:
	interrupted = true
	attack_done = true
	hide()


func _attempt_fire() -> void:
	if not interrupted:
		_spawn_impact(global_position)
	attack_done = true
	interrupted = false
	hide()


func _spawn_impact(pos: Vector2) -> void:
	var instance: DamageImpact = orb_explosion_scene.instantiate()
	instance.global_position = pos
	instance.damage = 1.0
	instance.set_collision_mask_value(3, true) # look for player
	get_tree().root.call_deferred("add_child", instance)
