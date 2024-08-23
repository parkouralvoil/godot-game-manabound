extends Area2D
class_name ChainLightning

@export var dmg_impact: PackedScene

@onready var line_container: Node2D = $lines
@onready var colshape: CollisionShape2D = $CollisionShape2D

var activated: bool = false

var line_array: Array[LightningSFX] = []
var targets: Array[Vector2] = []
var final_targets: Array[Vector2] = []
var max_targets: int = 1

var damage: float = 5
var starting_pos: Vector2
var checking_pos: Vector2

func _ready() -> void:
	for child in line_container.get_children():
		if child is LightningSFX:
			line_array.append(child)
			child.hide()
			max_targets += 1
	## if i eventually need pooling ill go back to this
	
	# spawn first impact at vector2.zero

func _physics_process(_delta: float) -> void:
	if activated:
		return
	activated = true
	targets.append(starting_pos)
	for area in get_overlapping_areas():
		if area is HurtboxComponent and area.global_position != starting_pos:
			targets.append(area.global_position)
		
	checking_pos = targets.pop_front()
	final_targets.append(checking_pos) 
	var loop_limit: int = min(max_targets - 1, targets.size())
	for i in range(loop_limit):
		targets.sort_custom(sort_by_pos)
		checking_pos = targets.pop_front()
		final_targets.append(checking_pos)
		#print(checking_pos)
	#print(pow(max_dist, 2) - check_pos.global_position.length_squared())
	loop_limit = min(max_targets, final_targets.size())
	if final_targets.size() > 1:
		for i in range(1, loop_limit):
			var pos1: Vector2 = final_targets[i-1]
			var pos2: Vector2 = final_targets[i]
			make_impact(pos1)
			make_impact(pos2)
			line_array[i-1].global_position = pos1
			line_array[i-1].goal_point = pos2
			line_array[i-1].show()
			

func make_impact(pos: Vector2) -> void:
	var instance: DamageImpact = dmg_impact.instantiate()
	instance.global_position = pos
	instance.damage = damage
	instance.element = CombatManager.Elements.LIGHTNING
	get_tree().root.call_deferred("add_child", instance)

func sort_by_pos(a: Vector2, b: Vector2) -> bool:
	var dist_a: float = (a - checking_pos).length_squared()
	var dist_b: float = (b - checking_pos).length_squared()
	if dist_a < dist_b:
		return true
	return false


func _on_timer_timeout() -> void:
	queue_free()
