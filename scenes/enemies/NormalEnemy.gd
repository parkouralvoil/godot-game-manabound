extends BaseEnemy
class_name NormalEnemy

@export var vision_range: float = 500.0 ## if enemy wants to use vision range
@export var is_small_drone: bool = false ## if enemy is small drone type

var can_fire: bool = false
var aim_direction: Vector2
var target_pos: Vector2


func _set_stats() -> void:
	super()
	if health_component is NormalEnemyHealth:
		health_component.set_healthbar_properties(stats.health)
	else:
		push_warning("possible error on %s, healthcomp is not type: NormalEnemyHealth" % name)
	mana_orbs_dropped = max_health
