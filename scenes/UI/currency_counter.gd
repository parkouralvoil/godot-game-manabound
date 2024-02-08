extends Label

func _process(delta):
	text = "Mana orbs: " + str(PlayerInfo.mana_orbs)
