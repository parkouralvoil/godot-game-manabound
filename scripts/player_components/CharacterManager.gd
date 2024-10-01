extends Node2D
class_name CharacterManager

@export var selected_team_info: SelectedTeamInfo ## for char_manager to communicate with UI's
	## remove "export" when adding more chars (after starter trio)

var data_array: Array[CharacterResource] = [null, null, null] ## the resource
var stored_chars: Array[Character] = [null, null, null] ## the scene, which has AbilityManager

var current_char: Character

var can_change_char: bool = true

@onready var p: Player = owner
@onready var t_change_char: Timer = $change_char_cd

func _ready() -> void:
	EventBus.returned_to_mainhub.connect(_on_returned_to_mainhub)
	data_array = selected_team_info.char_data_array
	for i in range(data_array.size()):
		stored_chars[i] = data_array[i].character_scene.instantiate()
		add_child(stored_chars[i])
		stored_chars[i].arm.hide()
		stored_chars[i].anim_sprite.hide()
		stored_chars[i].character_died.connect(_on_character_died)
	p.PlayerInfo.team_size = data_array.size()
	p.PlayerInfo.team_alive = data_array.size()
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
	if (stored_chars[num] != null 
			and current_char != stored_chars[num]
			and not stored_chars[num].is_dead):
		change_character(num)


func change_character(num: int) -> void:
	#if p.arm_sprite != null:
		#p.arm_sprite.hide()
		#p.wpn_sprite.hide()
	if current_char:
		current_char.anim_sprite.hide()
	var _char := data_array[num]
	var _AM := stored_chars[num]
	current_char = _AM
	current_char.anim_sprite.show()
	p.PlayerInfo.char_current_anim_sprite = current_char.anim_sprite ## needed to turn character red
	current_char.global_position = self.global_position
	p.PlayerInfo.melee_character = current_char.stats.melee ## tells PlayerInfo if current char is a melee char
	
	_AM.enabled = true
	_char.selected = true
	
	p.PlayerInfo.current_charge_type = current_char.stats.charge_type
	
	current_char.update_player_info()
	
	t_change_char.start()
	current_char.character_changed_anim()
	
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
#endregion


func _on_character_died() -> void:
	p.controls_disabled = true
	t_change_char.start()
	await t_change_char.timeout
	
	for i in range(stored_chars.size()):
		if not stored_chars[i]:
			continue ## null check
		if not stored_chars[i].is_dead:
			change_character(i)
			p.controls_disabled = false
			return
	
	print_debug("TODO: add gameover when no remaining character is alive.")


func _on_returned_to_mainhub() -> void:
	for i in range(stored_chars.size()):
		var char: Character = stored_chars[i]
		if not char:
			continue ## null check
		if char.is_dead:
			char.revive()
			char.stats.reset_stats()
	p.global_position = Vector2(1000, 1000) ## to hide player hehe
	p.controls_disabled = false
	change_character(0)
