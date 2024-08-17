extends Sprite2D
class_name RuneCollectible


enum RuneTypes {
	HP,
	ATK,
	EP,
	CHR,
}

const TextureHP: AtlasTexture = preload("res://resources/textures/runes/runeHP.tres")
const TextureATK: AtlasTexture = preload("res://resources/textures/runes/runeATK.tres")
const TextureEP: AtlasTexture = preload("res://resources/textures/runes/runeEP.tres")
const TextureCHR: AtlasTexture = preload("res://resources/textures/runes/runeCHR.tres")

@export var rune_type: RuneTypes = RuneTypes.ATK

func _ready() -> void:
	_change_texture_based_on_type()


func _change_texture_based_on_type() -> void:
	match rune_type:
		RuneTypes.HP:
			texture = TextureHP
		RuneTypes.ATK:
			texture = TextureATK
		RuneTypes.EP:
			texture = TextureEP
			modulate = Color(1, 1, 0.95) ## cuz it shines with WorldEnvironment glow sa main
		RuneTypes.CHR:
			texture = TextureCHR
