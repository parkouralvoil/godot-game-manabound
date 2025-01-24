extends CharacterBody2D
class_name Player

var PlayerInfo: PlayerInfoResource = preload("res://resources/data/player_info/player_info.tres")
var inventory: PlayerInventory = preload("res://resources/data/player_inventory/player_inventory.tres")

@export var direction_indicator: Sprite2D #= $DirectionIndicator
@export var circle_indicator: Sprite2D
@export var target_lock_component: Area2D #= $TargetLock
@export var player_hit_comp: PlayerHitComponent
@export var afterimage_comp: PlayerAfterimageComponent

# movement variables
var default_gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity: float = default_gravity

#var aim_direction: Vector2 = Vector2.ZERO # NOW STORED IN PlayerInfo, since other peeps need it
var move_direction: Vector2 = Vector2.ZERO #radians
#var mouse_direction: Vector2 = Vector2.ZERO
var dist_to_mouse: Vector2 = Vector2.ZERO

#target lock stuff
var selected_target: Area2D = null

var boost_index: int = 0
var boost_node_size: int = 0
var controls_disabled: int = false ## when character dies and respawning, set this to true

##onready var
@onready var hurtbox: Area2D = $AreaComponents/Hurtbox
@onready var boost_particles: Array[GPUParticles2D] = []
@onready var boost_sfx: AudioStreamPlayer2D = $BoostSpecialEffects/boost_sfx
@onready var buff_particles: GPUParticles2D = $BuffParticles


@onready var char_manager: CharacterManager = $CharacterManager
@onready var mobile_controls: bool = \
		ProjectSettings.get_setting("application/run/MobileControlsEnabled")

func _ready() -> void:
	EventBus.returned_to_mainhub.connect(_reset_player_inventory)
	var boost_node: Node2D = $BoostSpecialEffects
	char_manager.change_character(0)
	
	for i in boost_node.get_children():
		if i is GPUParticles2D:
			boost_particles.append(i)
			boost_node_size += 1
	
	PlayerInfo.changed_buff_raw_atk.connect(_on_buff_particles)


func _process(_delta: float) -> void:
	EnemyAiManager.player_position = global_position ## this seems too slow?
	## for airboost
	if mobile_controls:
		PlayerInfo.mouse_direction = Vector2.ZERO.direction_to(PlayerInfo.joystick_direction).normalized()
	else:
		dist_to_mouse = get_global_mouse_position() - self.global_position
		PlayerInfo.mouse_direction = Vector2.ZERO.direction_to(dist_to_mouse).normalized()
	## for slow hover
	if mobile_controls:
		if PlayerInfo.joystick_want_to_hover:
			move_direction = PlayerInfo.mouse_direction
		else:
			move_direction = Vector2.ZERO
	else:
		if Settings.inverted_hover:
			move_direction = Vector2.ZERO if dist_to_mouse.length() < 40 else PlayerInfo.mouse_direction
		else:
			move_direction = PlayerInfo.mouse_direction if dist_to_mouse.length() < 40 else Vector2.ZERO
	
	
	if (PlayerInfo.auto_aim 
			and selected_target != null 
			and (PlayerInfo.current_state != PlayerInfo.States.STANCE
				or mobile_controls)):
		PlayerInfo.aim_direction = Vector2.ZERO.direction_to(selected_target.global_position 
				- self.global_position).normalized()
		PlayerInfo.target_position = selected_target.global_position
	else:
		PlayerInfo.aim_direction = PlayerInfo.mouse_direction
		PlayerInfo.target_position = global_position
	
	if Input.is_action_just_pressed("toggle_aim"):
		PlayerInfo.auto_aim = not PlayerInfo.auto_aim


# cuz each character have their healths in AM
func take_damage(damage: int) -> void:
	if char_manager.current_char.is_dead:
		return
	char_manager.take_damage(damage)
	player_hit_comp.player_hit()
	PlayerInfo.player_got_hit.emit()


func emit_boost_effects(boost_dir: Vector2) -> void:
	boost_sfx.play()
	boost_particles[boost_index].emit_boost_particles(boost_dir)
	boost_index = clampi((boost_index + 1) % boost_node_size,
		0, 
		boost_node_size + 1)


func camera_shake(strength: int) -> void:
	EventBus.camera_shake.emit(strength)


func _on_buff_particles() -> void:
	if PlayerInfo.buff_raw_atk > 0:
		buff_particles.emitting = true
	else:
		buff_particles.emitting = false


func _reset_player_inventory() -> void:
	inventory.reset_inventory()
