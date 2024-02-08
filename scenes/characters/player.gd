extends CharacterBody2D
class_name Player

#onready var
@export var anim_sprite: AnimatedSprite2D
@export var arm_sprite: Sprite2D
@export var direction_indicator: Sprite2D
@export var camera: Camera2D
@export var target_lock_component: Area2D

@export var char_manager: AbilityManager

# input variables
var x_movement: float = 0
var y_movement: float = 0

# movement variables
var ground_speed: float = 140
var jump_speed: float = -200
var default_gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity: float = default_gravity


#logic
var airboost_ready: bool = false # ready's when jump release
var airboost_input: bool = false

var aim_direction: Vector2 = Vector2.ZERO #radians
var move_direction: Vector2 = Vector2.ZERO #radians
var mouse_direction: Vector2 = Vector2.ZERO
var dist_to_mouse: Vector2 = Vector2.ZERO

#target lock stuff
var auto_aim: bool = true
var selected_target: Area2D = null

func _process(delta):
	EnemyAiManager.player_position = global_position
	dist_to_mouse = get_global_mouse_position() - self.global_position
	# for airboost
	mouse_direction = Vector2.ZERO.direction_to(dist_to_mouse).normalized()
	
	# for slow hover
	move_direction = mouse_direction if dist_to_mouse.length() > 40 else Vector2.ZERO
	
	if auto_aim and selected_target != null:
		aim_direction = Vector2.ZERO.direction_to(selected_target.global_position - self.global_position).normalized()
	else:
		aim_direction = mouse_direction
	
	update_player_info()
	
	#arm rotation
	if PlayerInfo.basic_attacking:
		if anim_sprite.scale.x == 1:
			arm_sprite.rotation = aim_direction.angle() - (PI/2)
		else:
			arm_sprite.rotation = -(aim_direction.angle() - (PI/2))
	else:
		arm_sprite.rotation = 0
		
	if Input.is_action_just_pressed("tab"):
		auto_aim = !auto_aim

func take_damage(damage: float):
	if char_manager.health - damage > 0:
		char_manager.health -= damage
	else:
		char_manager.health = 0

func camera_shake(strength: int):
	if camera:
		camera.apply_noise_shake(strength)

func update_player_info():
	PlayerInfo.aim_direction = aim_direction
	PlayerInfo.mouse_direction = mouse_direction
