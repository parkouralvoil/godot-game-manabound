extends Node2D
class_name CharacterManager

# THE GENSHIN IS REAL

@export var knight_resource: CharacterResource
@export var witch_resource: CharacterResource

@onready var p: Player = get_parent()
@onready var t_change_char: Timer = $change_char_cd

var saved_AMs: Array[AbilityManager] = [null, null, null]
var selected_char: Array[CharacterResource] = [null, null, null]

var current_char_AM: AbilityManager
var current_char_spriteframes: SpriteFrames
var current_char_arm: Texture

var can_change_char: bool = true

func _ready() -> void:
	selected_char[0] = knight_resource
	assert(selected_char[0], "Missing reference to knight.")
	selected_char[1] = witch_resource
	assert(selected_char[1], "Missing reference to witch.")
	
	for i in range(2):
		saved_AMs[i] = selected_char[i].Ability_manager.instantiate()
		add_child(saved_AMs[i])
	
	change_character(0)

func take_damage(damage: float) -> void:
	if current_char_AM.health - damage > 0:
		current_char_AM.health -= damage
	else:
		current_char_AM.health = 0

func _process(_delta: float) -> void:
	if !p: return
	
	if p.anim_sprite.sprite_frames != current_char_spriteframes:
		p.anim_sprite.sprite_frames = current_char_spriteframes
		p.arm_sprite.texture = current_char_arm
	
	can_change_char = t_change_char.is_stopped() and !Input.is_action_pressed("right_click")
	
	if can_change_char:
		if Input.is_action_just_pressed("1") and current_char_AM != saved_AMs[0]:
			change_character(0)
			saved_AMs[1].enabled = false
			selected_char[1].selected = false
		elif Input.is_action_just_pressed("2") and current_char_AM != saved_AMs[1]:
			change_character(1)
			saved_AMs[0].enabled = false
			selected_char[0].selected = false

func change_character(num: int) -> void:
	var _char := selected_char[num]
	var _AM := saved_AMs[num]
	current_char_AM = _AM
	current_char_spriteframes = _char.spriteframes
	current_char_AM.global_position = self.global_position
	_AM.enabled = true
	_char.selected = true
	current_char_arm = _char.sprite_arm
	
	current_char_AM.update_player_info()
	
	t_change_char.start()
	p.character_changed_anim()

#region Transfer: AM > (CM) > Player
func set_player_velocity(velocity: Vector2) -> void:
	if p:
		p.velocity = velocity

func apply_player_cam_shake(strength: int) -> void:
	if p:
		p.camera_shake(strength)

func sprite_look_at(direction: Vector2) -> void:
	if p:
		if direction.x > 0:
			p.anim_sprite.scale.x = 1
		else:
			p.anim_sprite.scale.x = -1
#endregion
