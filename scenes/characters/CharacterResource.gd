extends Resource
class_name CharacterResource

@export var Ability_manager: PackedScene
@export var spriteframes: SpriteFrames
@export var sprite_arm: Texture
@export var sprite_portrait: Texture

@export var char_name: String = "woopsies"
var selected: bool = false

func _ready() -> void:
	assert(Ability_manager, "missing AM")
	assert(spriteframes, "missing spriteframes")
	assert(sprite_arm, "missing sprite arm")
	assert(sprite_portrait, "missing sprite portrait")
