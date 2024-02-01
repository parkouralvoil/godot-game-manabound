extends CharacterBody2D
class_name Player

#onready var
@export var anim_sprite: AnimatedSprite2D
@export var arm_sprite: Sprite2D
@export var direction_indicator: Sprite2D
@export var camera: Camera2D
@export var ammo_component: Node2D
@export var target_lock_component: Area2D

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

var is_firing: bool = false

# hp stuff
var max_health: float = 50.0
var health: float = max_health

#target lock stuff
var auto_aim: bool = true
var selected_target: Area2D = null

func _process(delta):
	EnemyAiManager.player_position = global_position
	move_direction = Vector2.ZERO.direction_to(get_global_mouse_position() - self.global_position).normalized()
	if auto_aim and selected_target != null:
		aim_direction = Vector2.ZERO.direction_to(selected_target.global_position - self.global_position).normalized()
	else:
		aim_direction = move_direction
	
	#arm rotation
	if is_firing:
		if anim_sprite.scale.x == 1:
			arm_sprite.rotation = aim_direction.angle() - (PI/2)
		else:
			arm_sprite.rotation = -(aim_direction.angle() - (PI/2))
	else:
		arm_sprite.rotation = 0
		
	if Input.is_action_just_pressed("tab"):
		auto_aim = !auto_aim

func take_damage(damage: float):
	if health - damage > 0:
		health -= damage
	else:
		health = 0

func camera_shake():
	if camera:
		camera.apply_noise_shake()
