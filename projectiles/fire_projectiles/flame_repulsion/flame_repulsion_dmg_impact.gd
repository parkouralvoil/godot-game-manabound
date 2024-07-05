extends DamageImpact

## has to clear all projectiles within the explosion
func _on_area_entered(hurtbox: Area2D) -> void:
	if hurtbox is HurtboxComponent:
		if hurtbox.has_method("hit"):
			hurtbox.hit(damage, element)
		if hurtbox.has_method("apply_debuff"):
			hurtbox.apply_debuff(debuff)
	elif hurtbox is Bullet: ## parry time
		if hurtbox.get_collision_layer_value(6) == true:
			hurtbox.queue_free()
