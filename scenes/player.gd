extends CharacterBody2D
class_name Player

signal PlayerDamaged

const PlayerInfo: PlayerInfoResource = preload("res://resources/data/player_info.tres")

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
var auto_aim: bool = true
var selected_target: Area2D = null

var boost_index: int = 0
var boost_node_size: int = 0

#onready var
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var arm_node: RemoteTransform2D = $AnimatedSprite2D/RemoteTransform2D
var arm_sprite: Sprite2D
var wpn_sprite: Sprite2D
@onready var fake_arm_sprite: Sprite2D = $AnimatedSprite2D/fake_arm
@onready var hurtbox: Area2D = $AreaComponents/Hurtbox
@onready var boost_particles: Array[GPUParticles2D] = []
@onready var boost_sfx: AudioStreamPlayer2D = $BoostSpecialEffects/boost_sfx
@onready var buff_particles: GPUParticles2D = $BuffParticles


@onready var char_manager: CharacterManager = $CharacterManager

func _ready() -> void:
	var boost_node: Node2D = $BoostSpecialEffects
	char_manager.change_character(0)
	
	for i in boost_node.get_children():
		if i is GPUParticles2D:
			boost_particles.append(i)
			boost_node_size += 1
	
	PlayerInfo.changed_buff_raw_atk.connect(on_buff_particles)


func _process(_delta: float) -> void:
	EnemyAiManager.player_position = global_position ## this seems too slow?
	dist_to_mouse = get_global_mouse_position() - self.global_position
	## for airboost
	PlayerInfo.mouse_direction = Vector2.ZERO.direction_to(dist_to_mouse).normalized()
	
	## for slow hover
	move_direction = PlayerInfo.mouse_direction if dist_to_mouse.length() < 40 else Vector2.ZERO
	
	if auto_aim and selected_target != null and PlayerInfo.current_state != PlayerInfo.States.STANCE:
		PlayerInfo.aim_direction = Vector2.ZERO.direction_to(selected_target.global_position - self.global_position).normalized()
	else:
		PlayerInfo.aim_direction = PlayerInfo.mouse_direction
	
	## can_charge setter
	match PlayerInfo.current_charge_type:
		PlayerInfoResource.ChargeTypes.BURST:
			PlayerInfo.can_charge = true
		_:
			if PlayerInfo.displayed_charge < PlayerInfo.displayed_MAX_CHARGE:
				PlayerInfo.can_charge = false
			else:
				PlayerInfo.can_charge = true
	
	## arm rotation
	if arm_sprite != null:
		if PlayerInfo.aim_direction.x > 0:
			arm_node.rotation = PlayerInfo.aim_direction.angle() - PI/2
		else:
			arm_node.rotation = -(PlayerInfo.aim_direction.angle() - (PI/2))
		
	if anim_sprite.animation == "fall" or anim_sprite.animation == "air" or (PlayerInfo.melee_character and PlayerInfo.basic_attacking):
		arm_sprite.hide()
		wpn_sprite.hide()
		fake_arm_sprite.hide()
	elif PlayerInfo.basic_attacking or PlayerInfo.input_ult:
		arm_sprite.show()
		wpn_sprite.show()
		fake_arm_sprite.hide()
	else:
		arm_sprite.hide()
		wpn_sprite.hide()
		fake_arm_sprite.show()
	
	
	if Input.is_action_just_pressed("tab"):
		auto_aim = !auto_aim


# cuz each character have their healths in AM
func take_damage(damage: int) -> void:
	char_manager.take_damage(damage)
	player_hit_comp.player_hit()
	PlayerDamaged.emit()


func emit_boost_effects(boost_dir: Vector2) -> void:
	boost_sfx.play()
	boost_particles[boost_index].emit_boost_particles(boost_dir)
	boost_index = clampi((boost_index + 1) % boost_node_size,
		0, 
		boost_node_size + 1)

func camera_shake(strength: int) -> void:
	EventBus.camera_shake.emit(strength)

#func update_player_info() -> void: ## can streamline this
	#PlayerInfo.aim_direction = aim_direction
	#PlayerInfo.mouse_direction = mouse_direction

func character_changed_anim() -> void:
	if anim_sprite:
		var tween: Tween = create_tween()
		tween.tween_property(anim_sprite, "modulate", Color(1,1,1,1), 0.4).from(Color(0.4,0.4,1, 0.6))


func on_buff_particles() -> void:
	if PlayerInfo.buff_raw_atk > 0:
		buff_particles.emitting = true
	else:
		buff_particles.emitting = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cheat_menu"):
			PlayerInfo.mana_orbs += 10000
