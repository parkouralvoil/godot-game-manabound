extends ProgressBar

func _process(delta: float) -> void:
	value = PlayerInfo.displayed_charge * 100 / PlayerInfo.displayed_max_charge
