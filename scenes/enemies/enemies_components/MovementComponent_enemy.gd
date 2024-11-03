extends CharacterBody2D
class_name EnemyMovementComponent

var max_speed: float = 40
var engage_speed: float = 5
var speed: float = max_speed

@onready var e: BaseEnemy = owner
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var player_raycast: RayCast2D = $Raycast_toPlayer

func _ready() -> void:
	nav_agent.max_speed = max_speed


func _physics_process(delta: float) -> void:
	e.global_position = self.global_position
	# movement and vision
	var vision_range := nav_agent.target_desired_distance
	var target_pos: Vector2 = e.target_pos
	var aim_direction: Vector2 = e.aim_direction
	target_pos = EnemyAiManager.player_position - global_position
	player_raycast.target_position = target_pos
	
	## fire only when target is nearby and in Line of sight
	## if close enough, slow down
	if target_pos.length() <= vision_range * 4 and not player_raycast.is_colliding():
		e.can_fire = true
		speed = max(speed - 400 * delta, engage_speed)
		e.sprite_main.rotation = target_pos.angle() - PI/2
	elif (target_pos.length() > vision_range * 2 or player_raycast.is_colliding()):
		e.can_fire = false
		speed = min(speed + 50 * delta, max_speed)
		e.sprite_main.rotation = lerp_angle(e.sprite_main.rotation, 
				aim_direction.angle() - PI/2, 
				5 * delta)
	
	## prepare next path, turn sprite
	var desired_direction: Vector2 = to_local(nav_agent.get_next_path_position() ).normalized()
	aim_direction = desired_direction
	var intended_velocity: Vector2 = desired_direction.normalized() * speed
	
	if nav_agent.is_navigation_finished() and e.can_fire:
		return
	
	nav_agent.set_velocity(intended_velocity)
	move_and_slide()


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	if speed == 0 and e.can_fire:
		velocity = Vector2.ZERO
	else:
		velocity = safe_velocity
	move_and_slide()


func _on_update_path_timeout() -> void:
	nav_agent.target_position = EnemyAiManager.player_position
