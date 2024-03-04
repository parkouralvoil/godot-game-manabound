extends Resource
class_name CharacterResource

@export var character_scene: PackedScene
@export var spriteframes: SpriteFrames
@export var sprite_arm: Texture
@export var sprite_portrait: Texture

@export var char_name: String = "woopsies"
var selected: bool = false

func _ready() -> void:
	assert(character_scene, "missing AM")
	if !character_scene.has_method("update_player_info"):
		push_error()
	assert(spriteframes, "missing spriteframes")
	assert(sprite_arm, "missing sprite arm")
	assert(sprite_portrait, "missing sprite portrait")
