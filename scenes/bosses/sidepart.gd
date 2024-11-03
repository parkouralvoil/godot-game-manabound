extends Sprite2D
class_name RailgunSidepart

@onready var independent_HP: float = 1000
@onready var boss: RailgunBoss = owner

func take_damage(damage: float, element: CombatManager.Elements, ep: float) -> void:
	if boss.current_phase == RailgunBoss.PHASE.ONE:
		pass
	else:
		## use own HP, can now be destroyed
		pass
