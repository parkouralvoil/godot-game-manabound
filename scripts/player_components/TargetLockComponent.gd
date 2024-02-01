extends Area2D

@export var p: Player
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var t_update: Timer = $update_target
var closest_target: Area2D = null

func _ready():
	collision_shape.shape.radius = 500

func _process(delta):
	if has_overlapping_areas() and (t_update.is_stopped() or closest_target == null):
		#print("rah" + str(get_overlapping_areas() ) )
		for enemy in get_overlapping_areas():
			if closest_target == null:
				closest_target = enemy
			elif (closest_target.global_position - p.global_position).length() > (enemy.global_position - p.global_position).length():
				closest_target = enemy
		p.selected_target = closest_target
		t_update.start()


func _on_update_target_timeout():
	pass # Replace with function body.
