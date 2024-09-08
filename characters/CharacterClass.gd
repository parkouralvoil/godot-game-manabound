extends Node2D
class_name Character

const PlayerInfo: PlayerInfoResource = preload("res://resources/data/player_info/player_info.tres")

@onready var anim_sprite: AnimatedSprite2D = $CharacterAnimationSprite
@onready var arm: Sprite2D = $CharacterAnimationSprite/arm
@onready var wpn: Sprite2D = $CharacterAnimationSprite/arm/weapon

## i want the AM to remain universal, the components are the ones who play around with eachother
@onready var CM: CharacterManager = get_parent()

## char_manager DOESNT have reference to char_data, 
## since char_data is the one that holds reference to this scene

var enabled: bool = false ## managed by char manager

@export var stats: CharacterStats


func _ready() -> void:
	## for current UI, tho honestly i can optimize this by making panel_char give info to current UI noh
	stats.max_HP_changed.connect(_on_stats_updated)
	stats.max_ammo_changed.connect(_on_stats_updated)
	stats.max_charge_changed.connect(_on_stats_updated)
	
	await get_tree().process_frame
	stats.reset_stats()
	print("%s has %0.2f EP" % [name, stats.EP])


func _process(_delta: float) -> void:
	if !enabled:
		return
	
	arm_updater()
	update_anim_sprite()
	update_PlayerInfo_sprite()
	
	## since these variables change frequently
	PlayerInfo.displayed_charge = stats.charge
	PlayerInfo.displayed_ammo = stats.ammo
	PlayerInfo.displayed_HP = stats.HP

#region Update Displayed UI
func _on_stats_updated() -> void:
	if enabled:
		PlayerInfo.displayed_MAX_HP = stats.MAX_HP
		PlayerInfo.displayed_MAX_AMMO = stats.MAX_AMMO
		PlayerInfo.displayed_MAX_CHARGE = stats.MAX_CHARGE
#endregion


func update_player_info() -> void: ## called by character manager maybe?
	PlayerInfo.displayed_MAX_AMMO = stats.MAX_AMMO
	PlayerInfo.displayed_MAX_HP = stats.MAX_HP
	PlayerInfo.displayed_MAX_CHARGE = stats.MAX_CHARGE


#region Transfer: (AM) > CM > Player
## i can remove this "intermediarry" transfer with signals, but then that'd mean that
## other entities could connect to use those signals,
## at the same time tho, this already works so why bother to change it?
func set_player_velocity(velocity: Vector2) -> void:
	if CM:
		CM.set_player_velocity(velocity)


func apply_player_cam_shake(strength: int) -> void:
	if CM:
		CM.apply_player_cam_shake(strength)


func sprite_look_at(direction: Vector2) -> void:
	if direction.x > 0:
		anim_sprite.scale.x = 1
		PlayerInfo.facing_direction = 1
	else:
		anim_sprite.scale.x = -1
		PlayerInfo.facing_direction = -1
#endregion


func arm_updater() -> void:
	## arm rotation
	if PlayerInfo.basic_attacking or PlayerInfo.input_ult:
		if PlayerInfo.aim_direction.x > 0:
			arm.rotation = PlayerInfo.aim_direction.angle() - PI/2
		else:
			arm.rotation = -(PlayerInfo.aim_direction.angle() - (PI/2))
		
	if (anim_sprite.animation == "fall" 
			or anim_sprite.animation == "air"
			or (PlayerInfo.melee_character and PlayerInfo.basic_attacking)):
		arm.hide()
		wpn.hide()
	elif PlayerInfo.basic_attacking or PlayerInfo.input_ult:
		arm.show()
		wpn.show()
	else:
		arm.show()
		arm.rotation = 0
		wpn.hide()


func character_changed_anim() -> void:
	var default := Color(1, 1, 1, 1)
	var faded_blue := Color(0.4, 0.4, 1, 0.6)
	var tween: Tween = create_tween()
	tween.tween_property(anim_sprite, "modulate", default, 0.4).from(faded_blue)


func update_anim_sprite() -> void:
	anim_sprite.play(PlayerInfo.current_anim)
	anim_sprite.scale.x = PlayerInfo.facing_direction


func update_PlayerInfo_sprite() -> void:
	var curr_anim := anim_sprite.animation
	var curr_frame := anim_sprite.get_frame()
	var spriteframes := anim_sprite.sprite_frames
	PlayerInfo.char_current_sprite = spriteframes.get_frame_texture(curr_anim, curr_frame)
