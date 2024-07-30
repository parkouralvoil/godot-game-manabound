extends BaseEnemy
class_name Enemy_LaserCrystal

@export var horizontal: bool = false
@export var spinning: bool = false
@onready var attack_comp: AttackComponent_LaserCrystal = $AttackComponent

var target: Array[Vector2] = [Vector2.DOWN, Vector2.UP]

func _ready() -> void:
	assert(health_component, "missing")
	health = max_health
	reload_time = default_reload_time
	assert(bullet_impact_scene, "missing ref")
	assert(enemy_dead_texture, "missing ref")
	EnemyAiManager.enemies_alive += 1
	
	if horizontal:
		sprite_main.rotation = PI/2
		target[0] = Vector2.LEFT
		target[1] = Vector2.RIGHT
	for i in range(2):
		attack_comp.laser[i].raycast.target_position = target[i] * attack_comp.max_range
		attack_comp.laser[i].update()
	process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(2).timeout
	process_mode = Node.PROCESS_MODE_INHERIT
	default_color = sprite_main.modulate


func _physics_process(delta: float) -> void:
	if not spinning:
		return
	
	var rot_speed: float = PI/30 * delta
	sprite_main.rotate(rot_speed)
	target[0] = target[0].rotated(rot_speed)
	target[1] = target[1].rotated(rot_speed)
	for i in range(2):
		attack_comp.laser[i].raycast.target_position = target[i] * attack_comp.max_range
		attack_comp.laser[i].update()
