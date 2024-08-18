extends Node2D
class_name CharacterManager

@export var selected_team_info: SelectedTeamInfo ## for char_manager to communicate with UI's
	## remove "export" when adding more chars (after starter trio)

var data_array: Array[CharacterResource] = [null, null, null] ## the resource
var stored_chars: Array[Character] = [null, null, null] ## the scene, which has AbilityManager

var current_char: Character
var current_char_spriteframes: SpriteFrames
var current_char_fake_arm: Texture

var can_change_char: bool = true

@onready var p: Player = owner
@onready var t_change_char: Timer = $change_char_cd

func _ready() -> void:
	data_array = selected_team_info.char_data_array
	for i in range(data_array.size()):
		stored_chars[i] = data_array[i].character_scene.instantiate()
		add_child(stored_chars[i])
		stored_chars[i].arm_sprite.hide()
		stored_chars[i].wpn_sprite.hide()
	#change_character(0) player calls this on its ready func instead


func take_damage(damage: int) -> void:
	if current_char.stats.HP - damage > 0:
		current_char.stats.HP -= damage
	else:
		current_char.stats.HP = 0


func _process(_delta: float) -> void:
	if !p: return
	
	can_change_char = t_change_char.is_stopped() and !Input.is_action_pressed("right_click")
	
	if can_change_char:
		if Input.is_action_just_pressed("1"):
			input_change_char(0)
		elif Input.is_action_just_pressed("2"):
			input_change_char(1)
		elif Input.is_action_just_pressed("3"):
			input_change_char(2)


func input_change_char(num: int) -> void:
	if stored_chars[num] != null and current_char != stored_chars[num]:
		change_character(num)


func change_character(num: int) -> void:
	if p.arm_sprite != null:
		p.arm_sprite.hide()
		p.wpn_sprite.hide()
	var _char := data_array[num]
	var _AM := stored_chars[num]
	current_char = _AM
	current_char_spriteframes = _char.spriteframes
	current_char_fake_arm = _char.sprite_arm
	current_char.global_position = self.global_position
	p.PlayerInfo.melee_character = current_char.stats.melee ## tells PlayerInfo if current char is a melee char
	
	_AM.enabled = true
	_char.selected = true
	
	p.anim_sprite.sprite_frames = current_char_spriteframes
	p.arm_node.remote_path = current_char.arm_sprite.get_path()
	p.PlayerInfo.current_charge_type = current_char.stats.charge_type
	p.arm_sprite = current_char.arm_sprite
	p.wpn_sprite = current_char.wpn_sprite
	
	p.fake_arm_sprite.texture = current_char_fake_arm
	
	current_char.update_player_info()
	
	t_change_char.start()
	p.character_changed_anim()
	
	for i in range(data_array.size()):
		if i != num and stored_chars[i] != null:
			data_array[i].selected = false
			stored_chars[i].enabled = false


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
