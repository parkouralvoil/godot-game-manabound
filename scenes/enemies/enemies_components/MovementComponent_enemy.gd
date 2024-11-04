extends CharacterBody2D
class_name EnemyMovementComponent

var max_speed: float = 80
var engage_speed: float = 20
var speed: float = max_speed

@onready var e: NormalEnemy = owner
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var player_raycast: RayCast2D = $Raycast_toPlayer

func _ready() -> void:
	nav_agent.max_speed = max_speed
	global_position = e.global_position
	assert(e.is_small_drone, "dont forget export")


func _physics_process(delta: float) -> void:
	## movement and vision
	var vision_range := nav_agent.target_desired_distance
	e.target_pos = EnemyAiManager.player_position - e.global_position
	player_raycast.target_position = e.target_pos
	
	
	## fire only when target is nearby and in Line of sight
	## if close enough, slow down
	if e.target_pos.length() <= vision_range * 4 and not player_raycast.is_colliding():
		e.can_fire = true
		speed = max(speed - 400 * delta, engage_speed)
		e.sprite_main.rotation = e.target_pos.angle() - PI/2
	elif (e.target_pos.length() > vision_range * 2 or player_raycast.is_colliding()):
		e.can_fire = false
		speed = min(speed + 50 * delta, max_speed)
		e.sprite_main.rotation = lerp_angle(e.sprite_main.rotation, 
				e.aim_direction.angle() - PI/2, 
				20 * delta)
	
	## prepare next path, turn sprite
	var desired_direction: Vector2 = to_local(nav_agent.get_next_path_position() )
	e.aim_direction = desired_direction
	var intended_velocity: Vector2 = desired_direction.normalized() * speed
	
	owner.global_position = global_position
	if nav_agent.is_navigation_finished() and e.can_fire:
		return
	
	nav_agent.set_velocity(intended_velocity)


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	if speed == 0 and e.can_fire:
		velocity = Vector2.ZERO
	else:
		velocity = safe_velocity
	move_and_slide()


func _on_update_path_timeout() -> void:
	nav_agent.target_position = EnemyAiManager.player_position
