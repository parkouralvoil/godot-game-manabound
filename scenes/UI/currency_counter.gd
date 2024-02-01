extends Label

func _process(delta):
	text = "Mana orbs: " + str(PlayerStuffManager.mana_orbs)
