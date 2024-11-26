extends Sprite2D
class_name RuneCollectible


## "projectile info"
var initial_speed: float
var throw_angle_degrees: float
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var time: float = 0.0

var initial_position: Vector2
var throw_direction: Vector2

var z_axis: float = 0.0 # simulate the arc
var is_launch: bool = false

func _ready() -> void:
	pass
	#launch_rune_from_chest(global_position, Vector2.RIGHT, 20, 80)


func _physics_process(delta: float) -> void:
	time += delta
	
	if is_launch:
		z_axis = initial_speed * sin(deg_to_rad(throw_angle_degrees)) * time - 0.5 * gravity * pow(time, 2)
		
		if z_axis > 0: ## hasnt landed yet
			var x_axis: float = initial_speed * cos(deg_to_rad(throw_angle_degrees)) * time
			var new_pos: Vector2 = initial_position + throw_direction * x_axis
			global_position = Vector2(new_pos.x, new_pos.y - z_axis)
	#print("z_axis: %0.2f" % z_axis)


func launch_rune_from_chest(from_pos: Vector2,
		direction: Vector2,
		desired_distance: float,
		desired_angle_deg: float) -> void:
	initial_position = from_pos
	throw_direction = direction.normalized()
	
	throw_angle_degrees = desired_angle_deg
	initial_speed = pow(desired_distance * gravity / sin(2 * deg_to_rad(desired_angle_deg)), 0.5)
	
	global_position = initial_position
	time = 0.0
	
	z_axis = 0
	is_launch = true


func _on_lifetime_timeout() -> void:
	var t: Tween = create_tween()
	t.tween_property(self, "modulate", Color(1, 1, 1, 0), 1).from(Color(1, 1, 1, 1))
	await t.finished
	hide()
