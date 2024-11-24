extends Bullet
class_name BulletRailgun

@export var BulletPath: PackedScene

func _on_body_entered(_body: TileMapLayer) -> void: # tilemap since thats the collision of the world
	spawn_projectiles()
	await get_tree().physics_frame
	disappear()


func shoot(projectile: PackedScene, _dir: Vector2, _spd: float) -> void:
	var pro_instance: Bullet = projectile.instantiate()
	if pro_instance:
		pro_instance.global_position = global_position
		
		pro_instance.speed = _spd
		pro_instance.direction = _dir
		pro_instance.rotation = _dir.angle()
		pro_instance.damage = 1.0
		pro_instance.set_collision_mask_value(3, true) ## to look for player
		pro_instance.set_collision_layer_value(6, true) ## for parry
		pro_instance.max_distance = 5000
		call_deferred("add_to_tree", pro_instance)
	elif pro_instance == null:
		print(projectile)


func spawn_projectiles() -> void:
	var offset: float = 30
	var new_speed := 200
	for i in range(12):
		var dir := Vector2.RIGHT.rotated(rotation + deg_to_rad(offset * i))
		shoot(BulletPath, dir, new_speed)


func add_to_tree(inst: Bullet) -> void:
	get_tree().root.add_child(inst)
