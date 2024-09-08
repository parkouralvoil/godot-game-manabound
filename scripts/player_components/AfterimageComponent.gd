extends Node2D
class_name PlayerAfterimageComponent

## why not a generic "after image" class? since player's sprites changes alot

@export var afterimage_scene: PackedScene ## spawns afterimage

@onready var p: Player = owner 
@onready var last_pos: Vector2 = p.global_position
@onready var curr_texture: Texture = null

var afterimages: int = 0

func _process(_delta: float) -> void:
	#if afterimages <= 0:
	#	return
	
	#var curr_anim: StringName = p.anim_sprite.animation
	#var curr_frame := p.anim_sprite.get_frame()
	#var spriteframes := p.anim_sprite.sprite_frames
	
	var is_green: bool = false if afterimages <= 0 else true
	
	curr_texture = p.PlayerInfo.char_current_sprite #spriteframes.get_frame_texture(curr_anim, curr_frame)
	if(p.global_position - last_pos).length_squared() > 250:
		last_pos = p.global_position
		spawn(afterimage_scene, curr_texture, is_green)
		afterimages = max(afterimages - 1, 0)
		#if p.anim_sprite.animation != "fall" and p.anim_sprite.animation != "air":
		#	spawn(afterimage_scene, p.arm_sprite.texture, is_green)


func spawn(scene: PackedScene, texture: Texture, is_green: bool) -> void:
	var img_instance: AfterImage = scene.instantiate()
	
	img_instance.scale.x = p.PlayerInfo.facing_direction #p.anim_sprite.scale.x
	img_instance.global_position = p.global_position
	img_instance.texture = texture
	if is_green:
		img_instance.scolor = img_instance.green_faded
		img_instance.ecolor = img_instance.green_transparent
	else:
		img_instance.scolor = img_instance.gray_faded
		img_instance.ecolor = img_instance.gray_transparent
	
	var level_node := get_tree().root
	level_node.call_deferred("add_child", img_instance)
