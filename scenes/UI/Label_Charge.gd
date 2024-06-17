extends Label

@export var p: Player


func _process(_delta: float) -> void:
	if !p:
		return
	var type: String = "Charge"
	match PlayerInfo.current_charge_type:
		PlayerInfo.ChargeTypes.BURST:
			type = "Charge"
		PlayerInfo.ChargeTypes.ENERGY:
			type = "Energy"
		PlayerInfo.ChargeTypes.PASSIVE:
			type = "Mana"
	
	var format_string: String = "%s: %d/%d"
	var actual_string: String = format_string % [type, 
		snapped(PlayerInfo.displayed_charge, 1), 
		PlayerInfo.displayed_max_charge]
	
	
	text = actual_string
	if PlayerInfo.displayed_charge >= 100:
		modulate = Color(1, 0.2, 0.2)
	elif PlayerInfo.displayed_charge >= 50:
		modulate = Color(1, 1, 0.2)
	elif PlayerInfo.displayed_charge >= 1:
		modulate = Color(1, 1, 1, 0.8)
	else:
		modulate = Color(0.6, 0.6, 0.6, 0.8)
