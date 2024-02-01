extends Area2D

var lightningProc_scene := load("res://scenes/projectiles/lightning_projectiles/lightning_impact.tscn")

var max_distance: float = 300.0
var speed: float = 300.0

var _travelled_distance = 0.0
var direction: Vector2 = Vector2.ZERO
var damage: float = 5.0

var impact_created: bool = false
var impact_pos: Vector2
var enemy_hit: bool = false

func _physics_process(delta: float):
	var distance: float = speed * delta
	var motion: Vector2 = transform.x * speed * delta
	
	position += motion
	
	_travelled_distance += distance
	if _travelled_distance > max_distance:
		disappear()

func _on_area_entered(hurtbox: Area2D):
	if hurtbox.has_method("hurtbox_hit"):
		enemy_hit = true
		impact_pos = hurtbox.global_position
		hurtbox.hurtbox_hit(damage)
	disappear()

func _on_body_entered(body):
	disappear()

func make_impact():
	if !enemy_hit:
		impact_pos = global_position
	if !impact_created:
		impact_created = true
		var instance: Area2D = lightningProc_scene.instantiate()
		instance.global_position = impact_pos
		get_tree().root.call_deferred("add_child", instance)

func disappear():
	make_impact()
	queue_free()
