extends Bullet

var first_icicle_dmg: float = 999
var second_icicle_dmg: float = 999

var first_icicle: bool = false

func _on_area_entered(hurtbox: Area2D) -> void:
	if hurtbox.has_method("hurtbox_hit"):
		hurtbox.hurtbox_hit(damage, element) # MORE PROCS!!!
	disappear()

func make_impact() -> void:
	if !impact_created:
		impact_created = true
		var instance: Area2D = bullet_impact.instantiate()
		instance.global_position = self.global_position
		
		instance.element = element # ice procced here
		instance.damage = first_icicle_dmg
		instance.second_icicle_dmg = second_icicle_dmg
		
		instance.first_icicle = first_icicle
		get_tree().root.call_deferred("add_child", instance)
