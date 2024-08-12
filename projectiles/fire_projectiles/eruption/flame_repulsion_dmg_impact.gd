extends DamageImpact

var can_generate_extra_energy: bool = false

## has to clear all projectiles within the explosion
func _on_area_entered(hurtbox: Area2D) -> void:
	if hurtbox is HurtboxComponent:
		if can_generate_extra_energy:
			EventBus.energy_gen_from_skills.emit(2)
		if hurtbox.has_method("hit"):
			hurtbox.hit(damage, element, ep)
		if hurtbox.has_method("apply_debuff"):
			hurtbox.apply_debuff(debuff, ep)
	elif hurtbox is Bullet: ## parry time
		if hurtbox.get_collision_layer_value(6) == true:
			hurtbox.queue_free()
		if can_generate_extra_energy:
			EventBus.energy_gen_from_skills.emit(2)
