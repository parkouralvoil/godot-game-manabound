extends BaseEnemy

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var player_raycast: RayCast2D = $Raycast_toPlayer

var vision_range: float = 500.0

var can_fire: bool = false
var aim_direction: Vector2 = Vector2(0,1)
var target_pos: Vector2

var max_speed: float = 70
var engage_speed: float = 0
var speed: float = max_speed


func _ready() -> void:
	assert(health_component, "missing")
	health = max_health
	reload_time = default_reload_time
	assert(bullet_impact_scene, "missing ref")
	assert(enemy_dead_texture, "missing ref")
	EnemyAiManager.enemies_alive += 1
	
	default_color = sprite_main.modulate
	
	nav_agent.max_speed = max_speed


func _physics_process(delta: float) -> void:
	# movement and vision
	var desired_direction: Vector2 = to_local(nav_agent.get_next_path_position() ).normalized()
	
	aim_direction = aim_direction.lerp(desired_direction, 4 * delta)
	
	behavior_pattern(delta)
	target_pos = EnemyAiManager.player_position - global_position
	player_raycast.target_position = target_pos
	# var temp_velocity: Vector2 = velocity
	var intended_velocity: Vector2 = aim_direction.normalized() * speed
	# for avoidance:
	nav_agent.set_velocity(intended_velocity)
	# for normal movement (when avoidance disabled)
	#velocity = intended_velocity
	#move_and_slide()
	
	
	# for bouncing
	#if get_slide_collision_count() > 0 and !can_fire:
		#var collision = get_slide_collision(0)
		#if collision != null:
			#aim_direction = temp_velocity.bounce(collision.get_normal())
			#speed = speed * 0.75
			

func _on_updatePath_timeout() -> void:
	nav_agent.target_position = EnemyAiManager.player_position

func behavior_pattern(input_delta: float) -> void:
	if target_pos.length() <= 140 and !player_raycast.is_colliding() and !can_fire:
		can_fire = true
	elif (target_pos.length() > 180 or player_raycast.is_colliding()) and can_fire:
		can_fire = false
	
	if can_fire:
		speed = max(speed - 200 * input_delta, engage_speed)
		sprite_main.rotation = target_pos.angle() - PI/2
	else:
		speed = min(speed + 50 * input_delta, max_speed)
		sprite_main.rotation = aim_direction.angle() - PI/2

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	if speed == 0 and can_fire:
		velocity = Vector2.ZERO
	else:
		velocity = safe_velocity
	move_and_slide()
