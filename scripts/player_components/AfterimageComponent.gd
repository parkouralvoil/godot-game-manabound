extends Node2D

@onready var p: Player = owner 

@export var afterimage_scene: PackedScene

@onready var last_pos: Vector2 = p.global_position

@onready var curr_texture: Texture = null

var afterimages: int = 0

func _process(_delta: float) -> void:
	if afterimages <= 0:
		return
	
	var curr_anim := p.anim_sprite.animation
	var curr_frame := p.anim_sprite.get_frame()
	var spriteframes := p.anim_sprite.sprite_frames
	curr_texture = spriteframes.get_frame_texture(curr_anim, curr_frame)
	if(p.global_position - last_pos).length_squared() > 400:
		last_pos = p.global_position
		afterimages -= 1
		spawn(afterimage_scene, curr_texture)
		spawn(afterimage_scene, p.arm_sprite.texture)


func spawn(scene: PackedScene, texture: Texture) -> void:
	var img_instance: Sprite2D = scene.instantiate()
	
	img_instance.scale.x = p.anim_sprite.scale.x
	img_instance.global_position = p.global_position
	img_instance.texture = texture
	
	var level_node := p.get_parent()
	level_node.call_deferred("add_child", img_instance)

