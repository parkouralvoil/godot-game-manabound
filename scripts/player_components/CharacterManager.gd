extends Node2D
class_name CharacterManager

# THE GENSHIN IS REAL

@export var knight_resource: CharacterResource
@export var witch_resource: CharacterResource

@onready var p: Player = get_parent()
@onready var t_change_char: Timer = $change_char_cd

var stored_chars: Array[Character] = [null, null, null]
var selected_char_resource: Array[CharacterResource] = [null, null, null]

var current_char: Character
var current_char_spriteframes: SpriteFrames
var current_char_fake_arm: Texture

var can_change_char: bool = true

# important logic:


func _ready() -> void:
	selected_char_resource[0] = knight_resource
	assert(selected_char_resource[0], "Missing reference to knight.")
	selected_char_resource[1] = witch_resource
	assert(selected_char_resource[1], "Missing reference to witch.")
	
	for i in range(2):
		stored_chars[i] = selected_char_resource[i].character_scene.instantiate()
		add_child(stored_chars[i])
		stored_chars[i].arm_sprite.hide()
		stored_chars[i].wpn_sprite.hide()
	
	#change_character(0) player calls this on its ready func instead

func take_damage(damage: float) -> void:
	if current_char.health - damage > 0:
		current_char.health -= damage
	else:
		current_char.health = 0

func _process(_delta: float) -> void:
	if !p: return
	
	can_change_char = t_change_char.is_stopped() and !Input.is_action_pressed("right_click")
	
	if can_change_char:
		if Input.is_action_just_pressed("1") and current_char != stored_chars[0]:
			change_character(0)
			stored_chars[1].enabled = false
			selected_char_resource[1].selected = false
		elif Input.is_action_just_pressed("2") and current_char != stored_chars[1]:
			change_character(1)
			stored_chars[0].enabled = false
			selected_char_resource[0].selected = false

func change_character(num: int) -> void:
	if p.arm_sprite != null:
		p.arm_sprite.hide()
		p.wpn_sprite.hide()
	var _char := selected_char_resource[num]
	var _AM := stored_chars[num]
	current_char = _AM
	current_char_spriteframes = _char.spriteframes
	current_char_fake_arm = _char.sprite_arm
	current_char.global_position = self.global_position
	_AM.enabled = true
	_char.selected = true
	
	p.anim_sprite.sprite_frames = current_char_spriteframes
	p.arm_node.remote_path = current_char.arm_sprite.get_path()
	p.arm_sprite = current_char.arm_sprite
	p.wpn_sprite = current_char.wpn_sprite
	p.arm_sprite.show()
	p.wpn_sprite.show()
	
	p.fake_arm_sprite.texture = current_char_fake_arm
	
	current_char.update_player_info()
	
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
