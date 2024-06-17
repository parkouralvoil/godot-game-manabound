extends Node2D
class_name Character

@onready var skill_tree: SkillTree = $AbilityManager/SkillTree
@onready var AM := $AbilityManager
@onready var arm_sprite: Sprite2D = $Sprite2D_arm
@onready var wpn_sprite: Sprite2D= $Sprite2D_arm/Sprite2D_wpn
#@onready var bullet_origin: Marker2D = $Sprite2D_arm/bullet_origin

# i want the AM to remain universal, the components are the ones who play around with eachother
@onready var CM: CharacterManager = get_parent()

var enabled: bool = false # managed by char manager
@export var charge_type: PlayerInfo.ChargeTypes = PlayerInfo.ChargeTypes.BURST
@export var melee: bool = false

@export_category("Initial Values")
@export var max_health: float = 50.0
var health: float = max_health :
	set(value):
		health = _on_health_change(value)

# basic atk
@export var max_ammo: int = 9 :
	set(value):
		max_ammo = _on_max_ammo_change(value)
var ammo: int = max_ammo :
	set(value):
		ammo = _on_ammo_change(value)

# ultimate
var max_charge: int = 50 : 
	set(value):
		max_charge = _on_max_charge_change(value)
var charge: float

var charge_rate: float = 0
@export var base_atk: int = 10
var atk: int

@export var fire_rate: float = 50


func _ready() -> void:
	skill_tree.hide()
	health = max_health
	ammo = max_ammo
	charge = 0
	atk = base_atk
	if AM.has_method("stats_update"):
		AM.stats_update()
		AM.desc_update()


func _process(_delta: float) -> void:
	if !enabled:
		if skill_tree.visible:
			skill_tree.hide()
		return


	if Input.is_action_just_pressed("shop_key") and !skill_tree.visible:
		skill_tree.show()
		get_tree().paused = true
	
	PlayerInfo.displayed_charge = charge


func _on_max_ammo_change(new_max_ammo: int) -> int:
	if enabled:
		PlayerInfo.on_max_ammo_changed.emit(new_max_ammo)
	return new_max_ammo #NOTE


func _on_ammo_change(new_ammo: int) -> int:
	if enabled:
		PlayerInfo.on_ammo_changed.emit(new_ammo)
	return new_ammo #NOTE


func _on_max_charge_change(new_max_charge: int) -> int:
	if enabled:
		PlayerInfo.on_max_charge_changed.emit(new_max_charge)
	return new_max_charge #NOTE


func _on_health_change(new_health: float) -> float:
	if enabled:
		PlayerInfo.on_health_changed.emit(new_health)
	return new_health # NOTE


func update_player_info() -> void:
	# make sure that nothing changed
	PlayerInfo.on_ammo_changed.emit(ammo)
	PlayerInfo.on_health_changed.emit(health)
	PlayerInfo.on_max_ammo_changed.emit(max_ammo)
	PlayerInfo.on_max_health_changed.emit(max_health)
	PlayerInfo.on_max_charge_changed.emit(max_charge)


#region Transfer: (AM) > CM > Player
# i can remove this needless "intermediarry" transfer with signals, but then that'd mean that
# other entities could connect to use those signals,
# at the same time tho, this already works so why bother to change it?
func set_player_velocity(velocity: Vector2) -> void:
	if CM:
		CM.set_player_velocity(velocity)


func apply_player_cam_shake(strength: int) -> void:
	if CM:
		CM.apply_player_cam_shake(strength)


func sprite_look_at(direction: Vector2) -> void:
	if CM:
		CM.sprite_look_at(direction)
#endregionmelee
