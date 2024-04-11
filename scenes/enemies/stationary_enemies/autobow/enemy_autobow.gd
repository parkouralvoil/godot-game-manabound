extends BaseEnemy
class_name Enemy_Autobow

var target_pos: Vector2 = Vector2.ZERO
var vision_range: float = 500.0

var can_fire: bool = false
var aim_direction: Vector2 = Vector2.ZERO

#attack component and ammo container:
var max_ammo: int = 3
var ammo: int = max_ammo

func _physics_process(_delta: float) -> void:
	# handles vision
	target_pos = EnemyAiManager.player_position
	can_fire = (target_pos - global_position).length() < vision_range
	
	if can_fire:
		aim_direction = Vector2.ZERO.direction_to(target_pos 
			- self.global_position).normalized()
