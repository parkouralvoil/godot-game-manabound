extends Area2D
class_name PlayerHitbox

@onready var p: Player = owner

# projectile was hitting player smh
# for a permanent fix, i can do smthg like
# (FOR ENTITIES) if entity is Player: set mask to player_hurtbox

# (FOR BULLETS) if bullet from player: set mask/layer to look for enemies

func _ready() -> void:
	self.monitorable = true
	p.PlayerInfo.character_died.connect(disable_hitbox.unbind(1))
	EventBus.returned_to_mainhub.connect(func() -> void: monitorable = true)

func hit(damage: int, _element: CombatManager.Elements, _ep: float = 0) -> void:
	if p.player_hit_comp.iframes <= 0:
		p.take_damage(damage)

func disable_hitbox() -> void:
	if p.PlayerInfo.team_alive == 0:
		set_deferred("monitorable", false)
