extends Node2D
class_name Character

var PlayerInfo: PlayerInfoResource = preload("res://resources/data/player_info.tres")

## MAKE ammo, charge, health, PART OF STATS RESOURCE

@onready var skill_tree: SkillTree = $AbilityManager/SkillTree
@onready var AM := $AbilityManager
@onready var arm_sprite: Sprite2D = $Sprite2D_arm
@onready var wpn_sprite: Sprite2D = $Sprite2D_arm/Sprite2D_wpn
#@onready var bullet_origin: Marker2D = $Sprite2D_arm/bullet_origin

# i want the AM to remain universal, the components are the ones who play around with eachother
@onready var CM: CharacterManager = get_parent()

var enabled: bool = false # managed by char manager

@export var stats: CharacterStats

@export_category("Kit Specific")
@export var charge_type: PlayerInfoResource.ChargeTypes = PlayerInfo.ChargeTypes.BURST
@export var melee: bool = false


func _ready() -> void:
	skill_tree.hide()
	stats.HP = stats.MAX_HP
	stats.ammo = stats.MAX_AMMO
	
	stats.max_HP_changed.connect(_on_max_health_change)
	stats.max_ammo_changed.connect(_on_max_ammo_change)
	stats.max_charge_changed.connect(_on_max_charge_change)
	
	if AM.has_method("stats_update"): ## temporary if condition, just for testing
		AM.stats_update()
		AM.desc_update()


func _process(_delta: float) -> void:
	if !enabled:
		if skill_tree.visible:
			skill_tree.hide()
		return
	if Input.is_action_just_pressed("shop_key") and !skill_tree.visible:
		skill_tree.show()
		skill_tree.selected_node = skill_tree.root_node
		get_tree().paused = true
	
	## since these variables change frequently
	PlayerInfo.displayed_charge = stats.charge
	PlayerInfo.displayed_ammo = stats.ammo
	PlayerInfo.displayed_HP = stats.HP


func _on_max_health_change() -> void:
	if enabled:
		PlayerInfo.displayed_MAX_HP = stats.MAX_HP


func _on_max_ammo_change() -> void:
	if enabled:
		PlayerInfo.displayed_MAX_AMMO = stats.MAX_AMMO


func _on_max_charge_change() -> void:
	if enabled:
		PlayerInfo.displayed_MAX_CHARGE = stats.MAX_CHARGE


func update_player_info() -> void:
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
#endregio
