extends Resource
class_name CharacterResource ## aka CharacterData

signal selected_changed()

@export_category("For Player")
@export var character_scene: PackedScene

@export_category("unused, transfered to character.tscn")
@export var spriteframes: SpriteFrames
@export var sprite_arm: Texture

@export_category("For Panel_Char and UIs")
@export var skill_tree_scene: PackedScene
@export var sprite_portrait: Texture
@export var sprite_window: Texture

@export var char_name: String = "woopsies"

## this is a HACK
## stuff needed for TeamInfoGrp
@export var stats: CharacterStats
## NOTICE: all text related stuff (names, descriptions) need to be transferred to a csv
## so it can be translated properly, but for now ugh
@export var basic_atk_name: String
@export var ult_name: String

var selected: bool = false:
	set(val):
		selected = val
		selected_changed.emit()

## purpose of CharacterResource is mainly for easier player communication

## this presents a minor dilemma for (character_stats) which needs have character_name as well

func _ready() -> void:
	assert(character_scene, "missing AM")
	if !character_scene.has_method("update_player_info"):
		push_error()
	assert(spriteframes, "missing spriteframes")
	assert(sprite_arm, "missing sprite arm")
	assert(sprite_portrait, "missing sprite portrait")
