extends Area2D


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is ManaOrb:
		var orb: ManaOrb = area.get_parent()
		orb.attract_orb()
