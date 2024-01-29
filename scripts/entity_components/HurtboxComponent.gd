extends Area2D

@export var entity: CharacterBody2D

# projectile was hitting player smh
# for a permanent fix, i can do smthg like
# (FOR ENTITIES) if entity is Player: set mask to player_hurtbox

# (FOR BULLETS) if bullet from player: set mask/layer to look for enemies

func hurtbox_hit(damage: float):
	entity.take_damage(damage)
