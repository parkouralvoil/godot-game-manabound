extends Area2D

@export var p: Player
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var t_update: Timer = $update_target
var closest_target: HurtboxComponent = null

# i prefer checking for enemy hurtbox rather than the enemy's center
# since some enemies might have multiple hurtboxes (aka weakpoints)

# Issues:
# seems expensive
# doesnt update once target is dead, has to wait for the queue free instead of checking hp
func _ready() -> void:
	collision_shape.shape.radius = 500

func _process(_delta: float) -> void:
	_update_target()

func _update_target() -> void:
	if has_overlapping_areas() and (t_update.is_stopped() or closest_target == null):
		#print("rah" + str(get_overlapping_areas() ) )
		for enemy in get_overlapping_areas():
			if closest_target == null:
				closest_target = enemy
			elif (closest_target.global_position - p.global_position).length() > (enemy.global_position - p.global_position).length():
				closest_target = enemy
		p.selected_target = closest_target
		t_update.start()
