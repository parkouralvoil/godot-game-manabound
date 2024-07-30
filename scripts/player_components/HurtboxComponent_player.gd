extends Area2D

@onready var p: Player = owner

# projectile was hitting player smh
# for a permanent fix, i can do smthg like
# (FOR ENTITIES) if entity is Player: set mask to player_hurtbox

# (FOR BULLETS) if bullet from player: set mask/layer to look for enemies

func hit(damage: int, _element: CombatManager.Elements) -> void:
	if p.player_hit_comp.iframes <= 0:
		p.take_damage(damage)
