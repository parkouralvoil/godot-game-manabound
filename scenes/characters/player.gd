extends CharacterBody2D
class_name Player

#onready var
@export var anim_sprite: AnimatedSprite2D
@export var direction_indicator: Sprite2D

# input variables
var x_movement: float = 0
var y_movement: float = 0

# movement variables
var ground_speed: float = 140
var jump_speed: float = -200
var default_gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity: float = default_gravity

var air_speed: float = 210
var air_deaccel: float = 60
var airboost_speed: float = 300

#logic
var airboost_ready: bool = false # ready's when jump release
var airboost_input: bool = false

var aim_direction: Vector2 = Vector2.ZERO #radians

func _process(delta):
	aim_direction = Vector2.ZERO.direction_to(get_global_mouse_position() - self.global_position).normalized()
