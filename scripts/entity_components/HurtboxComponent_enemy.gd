extends Area2D
class_name HurtboxComponent

@onready var entity: BaseEnemy = owner

# projectile was hitting player smh
# for a permanent fix, i can do smthg like
# (FOR ENTITIES) if entity is Player: set mask to player_hurtbox

# (FOR BULLETS) if bullet from player: set mask/layer to look for enemies


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE


func hit(damage: float, element: CombatManager.Elements, ep: float = 0) -> void:
	entity.take_damage(damage, element, ep)


func apply_debuff(debuff: CombatManager.Debuffs, ep: float = 0) -> void:
	entity.take_debuff(debuff, ep)
