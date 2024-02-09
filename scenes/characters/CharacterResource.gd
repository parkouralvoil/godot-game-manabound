extends Resource
class_name CharacterResource

@export var Ability_manager: PackedScene
@export var spriteframes: SpriteFrames
@export var sprite_arm: Texture

func _ready():
	assert(Ability_manager, "missing AM")
	assert(spriteframes, "missing spriteframes")
	assert(sprite_arm, "missing sprite arm")
