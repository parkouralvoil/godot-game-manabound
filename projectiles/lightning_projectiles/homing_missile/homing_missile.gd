extends Bullet
class_name HomingMissile

@onready var enemy_detector: Area2D = $enemy_detector
var _target: HurtboxComponent = null

var rotation_speed: float = 4.5

func _ready() -> void:
	assert(bullet_impact, "missing bullet impact")

func _physics_process(delta: float) -> void:
	var distance: float = speed * delta
	var _current_velocity: Vector2 = speed * Vector2.RIGHT.rotated(rotation)
	
	if _target != null:
		var target_direction := _target.global_position - global_position
		var angle_to: float = transform.x.angle_to(target_direction)
		rotate(sign(angle_to) * min(delta * rotation_speed, abs(angle_to)))
	if _target == null:
		_target = get_nearest_enemy()
	
	position += _current_velocity * delta
	
	_travelled_distance += distance
	if _travelled_distance > max_distance:
		disappear()

func get_nearest_enemy() -> HurtboxComponent:
	var nearest_enemy: HurtboxComponent
	for enemy in enemy_detector.get_overlapping_areas():
			var dist: float = position.distance_squared_to(enemy.global_position)
			if nearest_enemy == null:
				nearest_enemy = enemy
			elif dist < position.distance_squared_to(nearest_enemy.global_position):
				nearest_enemy = enemy
				
	return nearest_enemy

func _on_enemy_detector_area_entered(_area: Area2D) -> void:
	get_nearest_enemy()
