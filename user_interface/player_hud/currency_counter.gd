extends Label

@export var PlayerInfo: PlayerInfoResource

func _process(_delta: float) -> void:
	text = "Mana orbs: " + str(PlayerInfo.mana_orbs)
