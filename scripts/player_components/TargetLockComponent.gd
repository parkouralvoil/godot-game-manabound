extends Area2D

@export var p: Player
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
var closest_target: Area2D = null

func _ready():
	collision_shape.shape.radius = 500

func _process(delta):
	if has_overlapping_areas() and (Input.is_action_just_pressed("right_click") or closest_target == null):
		#print("rah" + str(get_overlapping_areas() ) )
		for enemy in get_overlapping_areas():
			if closest_target == null:
				closest_target = enemy
			elif (closest_target.global_position - p.global_position).length() > (enemy.global_position - p.global_position).length():
				closest_target = enemy
		p.selected_target = closest_target
