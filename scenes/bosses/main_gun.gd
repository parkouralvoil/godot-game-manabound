extends BaseEnemy
class_name RailgunMainGun

var target_pos: Vector2
var aim_direction: Vector2

func take_damage(damage: float, element: CombatManager.Elements, ep: float = 0) -> void:
	print_debug("test maingun take_damage")


func _physics_process(_delta: float) -> void:
	# handles vision
	
	aim_direction = Vector2.ZERO.direction_to(EnemyAiManager.player_position 
		- self.global_position).normalized()
	
	sprite_main.rotation = aim_direction.angle() - PI/2
