extends Sprite2D
class_name RailgunMainGun

var target_pos: Vector2
var aim_direction: Vector2

@onready var railpart: Sprite2D = $rail

func take_damage(damage: float, element: CombatManager.Elements, ep: float) -> void:
	print_debug("test maingun take_damage")


func _physics_process(_delta: float) -> void:
	# handles vision
	target_pos = EnemyAiManager.player_position
	
	aim_direction = Vector2.ZERO.direction_to(target_pos 
		- self.global_position).normalized()
	
	railpart.rotation = aim_direction.angle() - PI/2
