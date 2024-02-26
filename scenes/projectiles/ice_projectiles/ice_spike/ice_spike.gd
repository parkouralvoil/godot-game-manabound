extends Bullet

func _on_area_entered(hurtbox: Area2D) -> void:
	if hurtbox.has_method("hurtbox_hit"):
		hurtbox.hurtbox_hit(damage, CombatManager.Elements.NONE) # only impact procs the elems
	disappear()

func make_impact() -> void:
	if !impact_created:
		impact_created = true
		var instance: Area2D = bullet_impact.instantiate()
		instance.element = element # ice procced here
		instance.global_position = self.global_position
		instance.damage = round(damage/2)
		get_tree().root.call_deferred("add_child", instance)
