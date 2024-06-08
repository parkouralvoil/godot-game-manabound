extends Bullet

const chain_lightning_packed: PackedScene = preload("res://projectiles/lightning_projectiles/chain_lightning/chain_lightning.tscn")

var impact_pos: Vector2
var enemy_hit: bool = false

func _on_area_entered(hurtbox: Area2D) -> void:
	if hurtbox.has_method("hit"):
		enemy_hit = true
		impact_pos = hurtbox.global_position
		spawn_chain_lightning(impact_pos)
		hurtbox.call_deferred("hit", damage, element)
		# spawn lightning chain source
	disappear()

func make_impact() -> void:
	if !enemy_hit:
		impact_pos = global_position
	if !impact_created:
		impact_created = true
		var instance: Area2D = bullet_impact.instantiate()
		instance.global_position = impact_pos
		get_tree().root.call_deferred("add_child", instance)


func spawn_chain_lightning(global_pos: Vector2) -> void:
	var inst: Area2D = chain_lightning_packed.instantiate()
	inst.global_position = global_pos
	inst.starting_pos = global_pos ## HAS TO BE GLOBAL
	get_tree().root.call_deferred("add_child", inst)
