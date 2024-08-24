extends Resource
class_name RuneData

const inventory: PlayerInventory = preload("res://resources/data/player_inventory/player_inventory.tres")

@export var type: RuneType
@export var chance: float ## RAW CHANCE, has to be divided by total chance after
@export var texture: AtlasTexture

enum RuneType {
	HP,
	ATK,
	EP,
	CHR,
}

func collect_rune() -> void:
	match type:
		RuneType.HP:
			inventory.rune_HP += 1
		RuneType.ATK:
			inventory.rune_ATK += 1
		RuneType.EP:
			inventory.rune_EP += 1
		_:
			inventory.rune_CHR += 1
