extends BaseEnemy
class_name SidepartRailgun

@onready var boss: RailgunBoss = owner

func take_damage(damage: float, element: CombatManager.Elements, ep: float = 0) -> void:
	if boss.current_phase == RailgunBoss.PHASE.ONE:
		health_component.raw_damage_received(damage, element, ep)
	else:
		## use own HP, can now be destroyed
		pass
