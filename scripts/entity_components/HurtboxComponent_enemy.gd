extends Area2D
class_name HurtboxComponent

@onready var entity: Node

# projectile was hitting player smh
# for a permanent fix, i can do smthg like
# (FOR ENTITIES) if entity is Player: set mask to player_hurtbox

# (FOR BULLETS) if bullet from player: set mask/layer to look for enemies


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	if owner is BaseEnemy:
		entity = owner
	else: ## sideparts/boss
		entity = get_parent()


func hit(damage: float, element: CombatManager.Elements, ep: float = 0) -> void:
	#print_debug("ep received = %0.1f" % ep)
	if entity.has_method("take_damage"):
		entity.take_damage(damage, element, ep)


func apply_debuff(debuff: CombatManager.Debuffs, ep: float = 0) -> void:
	if entity.has_method("take_debuff"):
		entity.take_debuff(debuff, ep)
