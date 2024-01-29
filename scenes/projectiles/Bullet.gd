extends Area2D

var bulletSFX_scene := load("res://scenes/projectiles/bullet_impact.tscn")

var max_distance: float = 300.0
var speed: float = 300.0

var _travelled_distance = 0.0
var direction: Vector2 = Vector2.ZERO
var damage: float = 5.0

var impact_created: bool = false

func _physics_process(delta: float):
	var distance: float = speed * delta
	var motion: Vector2 = transform.x * speed * delta
	
	position += motion
	
	_travelled_distance += distance
	if _travelled_distance > max_distance:
		disappear()

func _on_area_entered(hurtbox: Area2D):
	if hurtbox.has_method("hurtbox_hit"):
		hurtbox.hurtbox_hit(damage)
	disappear()

func _on_body_entered(body):
	disappear()

func make_impact():
	if !impact_created:
		impact_created = true
		var instance: Sprite2D = bulletSFX_scene.instantiate()
		instance.global_position = global_position
		get_tree().root.add_child(instance)

func disappear():
	make_impact()
	queue_free()
