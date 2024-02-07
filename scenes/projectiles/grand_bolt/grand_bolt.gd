extends Area2D

var explosionProc_scene := load("res://scenes/projectiles/grand_bolt/explosion_impact.tscn")

var max_distance: float = 1000.0
var speed: float = 300.0

var _travelled_distance = 0.0
var direction: Vector2 = Vector2.ZERO
var damage: float = 20.0

var impact_pos: Vector2

var piercing: bool = false

func _physics_process(delta: float):
	var distance: float = speed * delta
	var motion: Vector2 = transform.x * speed * delta
	
	position += motion
	
	_travelled_distance += distance
	if _travelled_distance > max_distance:
		queue_free()

func _on_area_entered(hurtbox: Area2D):
	if hurtbox.has_method("hurtbox_hit"):
		hurtbox.hurtbox_hit(damage)
	if !piercing:
		make_impact()
		queue_free()

func _on_body_entered(body):
	make_impact()
	queue_free()

func make_impact():
	var instance: Area2D = explosionProc_scene.instantiate()
	instance.global_position = global_position
	get_tree().root.call_deferred("add_child", instance)
