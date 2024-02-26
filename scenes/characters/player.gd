extends CharacterBody2D
class_name Player

#onready var
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var arm_sprite: Sprite2D = $AnimatedSprite2D/Sprite2D_arm
@export var direction_indicator: Sprite2D #= $DirectionIndicator
@export var target_lock_component: Area2D #= $TargetLock
@export var player_hit_comp: Node2D
@export var afterimage_comp: Node2D
@onready var hurtbox: Area2D = $Hurtbox

#UI stuff (connect these in the level scene)
@export var camera: Camera2D 
@export var blood_overlay: TextureRect

@onready var char_manager: CharacterManager = $CharacterManager

# input variables
var x_movement: float = 0
var y_movement: float = 0

# movement variables
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

func _process(_delta: float) -> void:
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
	
	#print(str(get_viewport_rect().size) )
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
# cuz each character have their healths in AM
func take_damage(damage: float) -> void:
	char_manager.take_damage(damage)
	player_hit_comp.player_hit()
	
	if blood_overlay:
		blood_overlay.display_blood()

func camera_shake(strength: int) -> void:
	if camera:
		camera.apply_noise_shake(strength)

func update_player_info() -> void:
	PlayerInfo.aim_direction = aim_direction
	PlayerInfo.mouse_direction = mouse_direction

func character_changed_anim() -> void:
	if anim_sprite:
		var tween: Tween = create_tween()
		tween.tween_property(anim_sprite, "modulate", Color(1,1,1,1), 0.4).from(Color(0.4,0.4,1, 0.6))
