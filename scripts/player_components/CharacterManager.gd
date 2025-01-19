extends Node2D
class_name CharacterManager

@export var selected_team_info: SelectedTeamInfo ## for char_manager to communicate with UI's
	## remove "export" when adding more chars (after starter trio)

var current_char: Character
var _current_index: int = 0

var _data_array: Array[CharacterResource] = [null, null, null] ## the resource
var _stored_chars: Array[Character] = [null, null, null] ## the scene, which has AbilityManager

var _can_change_char: bool = true
var _tutorial_restriction: int = 3
var _tutorial_immortality: bool = false

@onready var p: Player = owner
@onready var t_change_char: Timer = $change_char_cd

func _ready() -> void:
	EventBus.returned_to_mainhub.connect(_on_returned_to_mainhub)
	EventBus.tutorial_team_restriction_set.connect(_update_tutorial_restriction)

	PlayerInput.character_index_switch.connect(_on_character_index_switch) # for PC
	PlayerInput.character_switch_left.connect(_on_character_switch_left) # for mobile
	PlayerInput.character_switch_right.connect(_on_character_switch_right) # for mobile

	_data_array = selected_team_info.char_data_array
	for i in range(_data_array.size()):
		_stored_chars[i] = _data_array[i].character_scene.instantiate()
		add_child(_stored_chars[i])
		_stored_chars[i].arm.hide()
		_stored_chars[i].anim_sprite.hide()
		_stored_chars[i].character_died.connect(_on_character_died)
	p.PlayerInfo.team_size = _data_array.size()
	p.PlayerInfo.team_alive = _data_array.size()

	EventBus.swapped_character.emit(_current_index, _stored_chars.size() - 1)
	#change_character(0) player calls this on its ready func instead


func take_damage(damage: int) -> void:
	print_debug("took damage")
	if _tutorial_immortality and current_char.stats.hp <= 1:
		print_debug("tutorial immunity?")
		return
	if current_char.stats.hp - damage > 0:
		print_debug("damage received")
		current_char.stats.hp -= damage
	else:
		print_debug("should be dead")
		current_char.stats.hp = 0


func _process(_delta: float) -> void:
	if !p: return
	
	_can_change_char = t_change_char.is_stopped() and not PlayerInput.pressing_ult


func _input_change_char(num: int) -> void:
	if (_stored_chars[num] != null 
			and current_char != _stored_chars[num]
			and not _stored_chars[num].is_dead):
		change_character(num)

func change_character(num: int) -> void:
	if current_char:
		current_char.anim_sprite.hide()
	var _char := _data_array[num]
	var _AM := _stored_chars[num]
	current_char = _AM
	_current_index = num
	current_char.anim_sprite.show()
	p.PlayerInfo.char_current_anim_sprite = current_char.anim_sprite ## needed to turn character red
	current_char.global_position = self.global_position
	p.PlayerInfo.melee_character = current_char.stats.melee ## tells PlayerInfo if current char is a melee char
	
	_AM.enabled = true
	_char.selected = true
	
	current_char.update_player_info()
	
	t_change_char.start()
	current_char.character_changed_anim()
	
	for i in range(_data_array.size()):
		if i != num and _stored_chars[i] != null:
			_data_array[i].selected = false
			_stored_chars[i].enabled = false
	EventBus.swapped_character.emit(_current_index, _stored_chars.size() - 1)


#region Transfer: AM > (CM) > Player
func set_player_velocity(velocity: Vector2) -> void:
	if p:
		p.velocity = velocity


func apply_player_cam_shake(strength: int) -> void:
	if p:
		p.camera_shake(strength)
#endregion


func _on_character_died() -> void:
	print_debug("char died")
	p.controls_disabled = true
	p.PlayerInfo.recoiling_from_basic_atk = false
	p.PlayerInfo.input_ult = false
	t_change_char.start()
	await t_change_char.timeout
	
	for i in range(_stored_chars.size()):
		if not _stored_chars[i]:
			continue ## null check
		if not _stored_chars[i].is_dead:
			change_character(i)
			p.controls_disabled = false
			return


func _on_returned_to_mainhub() -> void:
	for i in range(_stored_chars.size()):
		var c: Character = _stored_chars[i]
		if not c:
			continue ## null check
		if c.is_dead:
			c.revive()
		c.stats.reset_stats()
	p.global_position = Vector2(1000, 1000) ## to hide player hehe
	p.controls_disabled = false
	change_character(0)


func _update_tutorial_restriction(tutorial_level: int) -> void:
	_input_change_char(0) ## always return to knight
	_tutorial_restriction = tutorial_level
	if _tutorial_restriction <= 2:
		_tutorial_immortality = true
	else:
		_tutorial_immortality = false
	#print_debug("_tutorial_restriction: ", _tutorial_restriction)

func _on_character_index_switch(i: int) -> void:
	if not _can_change_char:
		return

	match i:
		1:
			_input_change_char(0)
		2:
			if _tutorial_restriction >= 2:
				_input_change_char(1)
		3:
			if _tutorial_restriction >= 3:
				_input_change_char(2)
		_:
			pass

func _on_character_switch_left() -> void:
	var one_based_index: int = _current_index + 1
	if one_based_index > 1:
		_on_character_index_switch(one_based_index - 1)

func _on_character_switch_right() -> void:
	var one_based_index: int = _current_index + 1
	if one_based_index < 3:
		_on_character_index_switch(one_based_index + 1)
