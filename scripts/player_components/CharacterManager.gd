extends Node2D
class_name CharacterManager

# THE GENSHIN IS REAL

@export var knight_resource: CharacterResource
@export var witch_resource: CharacterResource

@onready var p: Player = get_parent()

var saved_AMs: Array[AbilityManager] = [null, null, null]
var selected_char: Array[CharacterResource] = [null, null, null]

var current_char_AM: AbilityManager
var current_char_spriteframes: SpriteFrames
var current_char_arm: Texture

func _ready():
	selected_char[0] = knight_resource
	assert(selected_char[0], "Missing reference to knight.")
	selected_char[1] = witch_resource
	assert(selected_char[1], "Missing reference to witch.")
	
	for i in range(2):
		saved_AMs[i] = selected_char[i].Ability_manager.instantiate()
		add_child(saved_AMs[i])
	
	change_character(1)

func take_damage(damage: float):
	if current_char_AM.health - damage > 0:
		current_char_AM.health -= damage
	else:
		current_char_AM.health = 0

func _process(delta):
	if !p: return
	
	if p.anim_sprite.sprite_frames != current_char_spriteframes:
		p.anim_sprite.sprite_frames = current_char_spriteframes
		p.arm_sprite.texture = current_char_arm
	
	if Input.is_action_just_pressed("1") and current_char_AM != saved_AMs[0]:
		change_character(0)
		
		saved_AMs[1].enabled = false
		print(str(saved_AMs[1]) + " >>> " + str(saved_AMs[1].enabled))
	elif Input.is_action_just_pressed("2") and current_char_AM != saved_AMs[1]:
		change_character(1)
		
		saved_AMs[0].enabled = false
		print(str(saved_AMs[0]) + " >>> " + str(saved_AMs[0].enabled))

func change_character(num: int):
	var char = selected_char[num]
	var AM = saved_AMs[num]
	current_char_AM = AM
	current_char_spriteframes = char.spriteframes
	current_char_AM.global_position = self.global_position
	AM.enabled = true
	print(str(AM) + " ::: " + str(AM.enabled))
	current_char_arm = char.sprite_arm

#region Transfer: AM > (CM) > Player
func set_player_velocity(velocity: Vector2):
	if p:
		p.velocity = velocity

func apply_player_cam_shake(strength: int):
	if p:
		p.camera_shake(strength)

func sprite_look_at(direction: Vector2):
	if p:
		if direction.x > 0:
			p.anim_sprite.scale.x = 1
		else:
			p.anim_sprite.scale.x = -1
#endregion
