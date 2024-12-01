extends DamageImpact

@export var sword_impact_particle: ParticleProcessMaterial
var can_generate_extra_energy: bool = false

func _on_area_entered(hurtbox: Area2D) -> void:
	if hurtbox.has_method("hit"):
		var pos := hurtbox.global_position
		var dir := Vector2.RIGHT.rotated(rotation)
		hurtbox.hit(damage, element, ep)
		SoundPlayer.play_sword_impact_sound()
		ParticlesQueueNode.set_property_restart(
			sword_impact_particle,
			null,
			true,
			12,
			0.85,
			0.6,
			pos,
			dir,
		)
		if can_generate_extra_energy:
			EventBus.energy_gen_from_skills.emit(1)
	if hurtbox.has_method("apply_debuff"):
		hurtbox.apply_debuff(debuff, ep)
