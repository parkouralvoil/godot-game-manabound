extends Resource
class_name CharacterResource ## aka CharacterData

@export_category("For Player")
@export var character_scene: PackedScene
@export var spriteframes: SpriteFrames
@export var sprite_arm: Texture

@export_category("For Panel_Char and UIs")
@export var skill_tree_scene: PackedScene
@export var sprite_portrait: Texture
@export var sprite_window: Texture

@export var char_name: String = "woopsies"

## this is a fuckin HACK
## stuff needed for TeamInfoGrp
@export var stats: CharacterStats
## NOTICE: all text related stuff (names, descriptions) need to be transferred to a csv
## so it can be translated properly, but for now ugh
@export var basic_atk_name: String
@export var ult_name: String

var selected: bool = false

## purpose of CharacterResource is mainly for easier player communication

## this presents a dilemma for (character_stats) which needs have character_name as well
"""
in the end, PLAYER_HOLDER is the one that informs the panel_char about the portrait

so it also makes sense to make PLAYER_HOLDER inform the team_info_grp about the stree's and frame

character_manager only focuses on
- character to player interactions
- loading the 3 characters

player_holder is the dependency injector 
"""

func _ready() -> void:
	assert(character_scene, "missing AM")
	if !character_scene.has_method("update_player_info"):
		push_error()
	assert(spriteframes, "missing spriteframes")
	assert(sprite_arm, "missing sprite arm")
	assert(sprite_portrait, "missing sprite portrait")
