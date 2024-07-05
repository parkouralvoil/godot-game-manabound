extends Label

@export var p: Player


func _process(_delta: float) -> void:
	if !p:
		return
	var type: String
	match p.PlayerInfo.current_charge_type:
		p.PlayerInfo.ChargeTypes.BURST:
			type = "Charge"
		p.PlayerInfo.ChargeTypes.PASSIVE:
			type = "Mana"
		_:
			type = "Energy"
	
	var format_string: String = "%s: %d/%d"
	var actual_string: String = format_string % [type, 
		snapped(p.PlayerInfo.displayed_charge, 1), 
		p.PlayerInfo.displayed_MAX_CHARGE]
	
	
	text = actual_string
	if p.PlayerInfo.displayed_charge >= 100:
		modulate = Color(1, 0.2, 0.2)
	elif p.PlayerInfo.displayed_charge >= 50:
		modulate = Color(1, 1, 0.2)
	elif p.PlayerInfo.displayed_charge >= 1:
		modulate = Color(1, 1, 1, 0.8)
	else:
		modulate = Color(0.6, 0.6, 0.6, 0.8)
