extends Node2D
class_name LightningLine
## SOURCE: https://github.com/Geminimax/Godot-2d-Lightning

var goal_point : Vector2 = Vector2(100,100)
var min_segment_size : float = 2
var max_segment_size : float = 10
var points : Array = []
var emitting: bool = true
var final_goal : Vector2

@export var angle_var: float = 15

@onready var line: Line2D = $Line2D
@onready var timer: Timer = $Timer

func _ready() -> void:
	final_goal = goal_point - global_position 
	timer.start(randf_range(0.1,0.3))

func _on_Timer_timeout() -> void:
	if(points.size() > 0):
		points.pop_front()
		line.points = points	
			
		#Small variation for more organic look:
		$Timer.start(0.002 + randf_range(-0.001,0.001))
	elif(emitting):
		update_points()
		line.points = points	
		$Timer.start(0.1 + randf_range(-0.02,0.1))
	
func update_points() -> void:
	final_goal = goal_point - global_position 
	var curr_line_len: float = 0
	points = [Vector2()]
	var start_point: Vector2 = Vector2()
	min_segment_size = max(Vector2().distance_to(final_goal)/40,1)
	max_segment_size = min(Vector2().distance_to(final_goal)/20,10)
	while(curr_line_len < Vector2().distance_to(final_goal)):
		var move_vector: Vector2 = start_point.direction_to(final_goal) * randf_range(min_segment_size,max_segment_size)
		var new_point: Vector2 = start_point + move_vector
		var new_point_rotated: Vector2 = start_point + move_vector.rotated(deg_to_rad(randf_range(-angle_var,angle_var)))
		points.append(new_point_rotated)
		start_point = new_point
		curr_line_len = start_point.length()
		
	points.append(final_goal)

func set_line_width(amount: float) -> void:
	line.width = amount
