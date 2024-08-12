extends Bullet
class_name IceSpikeBullet

var first_icicle_dmg: float = 999
var second_icicle_dmg: float = 999

var first_icicle: bool = false
var debuff: CombatManager.Debuffs = CombatManager.Debuffs.NONE

func _on_area_entered(hurtbox: Area2D) -> void:
	if hurtbox.has_method("hit"):
		hurtbox.hit(damage, element, ep)
	if hurtbox.has_method("apply_debuff"):
		hurtbox.apply_debuff(debuff, ep)
	disappear()

func make_impact() -> void:
	if !impact_created:
		impact_created = true
		var instance: IceSpikeDamageImpact = bullet_impact.instantiate()
		instance.global_position = self.global_position
		
		instance.ep = ep
		instance.element = element # ice procced here
		instance.damage = first_icicle_dmg
		instance.second_icicle_dmg = second_icicle_dmg
		instance.debuff = debuff
		
		instance.first_icicle = first_icicle
		get_tree().root.call_deferred("add_child", instance)
