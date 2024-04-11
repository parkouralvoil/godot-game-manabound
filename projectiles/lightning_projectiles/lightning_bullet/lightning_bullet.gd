extends Bullet

var impact_pos: Vector2
var enemy_hit: bool = false

func _on_area_entered(hurtbox: Area2D) -> void:
	if hurtbox.has_method("hit"):
		enemy_hit = true
		impact_pos = hurtbox.global_position
		hurtbox.hit(damage, element)
	disappear()

func make_impact() -> void:
	if !enemy_hit:
		impact_pos = global_position
	if !impact_created:
		impact_created = true
		var instance: Area2D = bullet_impact.instantiate()
		instance.global_position = impact_pos
		get_tree().root.call_deferred("add_child", instance)
