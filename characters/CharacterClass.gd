extends Node2D
class_name Character

var PlayerInfo: PlayerInfoResource = preload("res://resources/data/player_info.tres")

@onready var arm_sprite: Sprite2D = $Sprite2D_arm
@onready var wpn_sprite: Sprite2D = $Sprite2D_arm/Sprite2D_wpn

## i want the AM to remain universal, the components are the ones who play around with eachother
@onready var CM: CharacterManager = get_parent()

## char_manager DOESNT have reference to char_data, 
## since char_data is the one that holds reference to this scene

var enabled: bool = false ## managed by char manager

@export var stats: CharacterStats

@export_category("Kit Specific")
## this is now part of Stats
#@export var charge_type: PlayerInfoResource.ChargeTypes = PlayerInfo.ChargeTypes.CHARGE
#@export var melee: bool = false


func _ready() -> void:
	## for current UI, tho honestly i can optimize this by making panel_char give info to current UI noh
	stats.max_HP_changed.connect(_on_max_health_change)
	stats.max_ammo_changed.connect(_on_max_ammo_change)
	stats.max_charge_changed.connect(_on_max_charge_change)
	
	await get_tree().process_frame
	stats.reset_stats()


func _process(_delta: float) -> void:
	if !enabled:
		return
	
	## since these variables change frequently
	PlayerInfo.displayed_charge = stats.charge
	PlayerInfo.displayed_ammo = stats.ammo
	PlayerInfo.displayed_HP = stats.HP

#region Update Displayed UI
func _on_max_health_change() -> void:
	if enabled:
		PlayerInfo.displayed_MAX_HP = stats.MAX_HP


func _on_max_ammo_change() -> void:
	if enabled:
		PlayerInfo.displayed_MAX_AMMO = stats.MAX_AMMO


func _on_max_charge_change() -> void:
	if enabled:
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
	if CM:
		CM.sprite_look_at(direction)
#endregion
