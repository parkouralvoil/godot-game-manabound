extends Bullet

var piercing: bool = false

func _on_area_entered(hurtbox: Area2D) -> void:
	if hurtbox.has_method("hurtbox_hit"):
		hurtbox.hurtbox_hit(damage, element)
		make_impact()
	if !piercing:
		disappear()

func make_impact() -> void:
	var instance: Area2D = bullet_impact.instantiate()
	instance.global_position = global_position
	get_tree().root.call_deferred("add_child", instance)
