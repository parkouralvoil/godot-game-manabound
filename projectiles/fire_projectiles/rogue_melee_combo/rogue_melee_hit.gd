extends DamageImpact

var can_generate_extra_energy: bool = false

func _on_area_entered(hurtbox: Area2D) -> void:
	if hurtbox.has_method("hit"):
		hurtbox.hit(damage, element, ep)
		SoundPlayer.play_sword_impact_sound()
		if can_generate_extra_energy:
			EventBus.energy_gen_from_skills.emit(1)
	if hurtbox.has_method("apply_debuff"):
		hurtbox.apply_debuff(debuff, ep)
