extends Area2D

@export var p: Player
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var t_update: Timer = $update_target
@onready var target_guide: Sprite2D = $target_crosshair
@onready var raycast_can_hit: RayCast2D = $RayCast2D
var closest_target: HurtboxComponent = null

# i prefer checking for enemy hurtbox rather than the enemy's center
# since some enemies might have multiple hurtboxes (aka weakpoints)

# Issues:
# seems expensive
# doesnt update once target is dead, has to wait for the queue free instead of checking hp
func _ready() -> void:
	@warning_ignore("unsafe_property_access") ## this aint unsafe bruh godot just tripping
	collision_shape.shape.radius = 500

func _process(_delta: float) -> void:
	if not p.PlayerInfo.auto_aim or closest_target == null:
		target_guide.hide()
	else:
		target_guide.show()
		target_guide.rotate(PI/2 * _delta)
		target_guide.global_position = closest_target.global_position
			## might be better to have a remotetransform on the enemy

func _update_target() -> void:
	if not p.PlayerInfo.auto_aim:
		p.selected_target = null
		return
	
	if has_overlapping_areas(): # and (t_update.is_stopped() or closest_target == null):
		#print("rah" + str(get_overlapping_areas() ) )
		for enemy in get_overlapping_areas():
			raycast_can_hit.target_position = enemy.global_position - global_position
			raycast_can_hit.force_raycast_update()
			if raycast_can_hit.is_colliding():
				if closest_target == enemy:
					closest_target = null
				continue
			if closest_target == null:
				closest_target = enemy
			elif (closest_target.global_position - p.global_position).length_squared() > (enemy.global_position - 
					p.global_position).length_squared():
				closest_target = enemy
		if is_instance_valid(closest_target):
			p.selected_target = closest_target
		t_update.start()


func _on_update_target_timeout() -> void:
	_update_target()
