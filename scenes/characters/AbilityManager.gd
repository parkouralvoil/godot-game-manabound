extends Node2D
class_name AbilityManager

@onready var skill_tree: CanvasLayer = $SkillTree
@onready var CM: CharacterManager = get_parent()

var enabled: bool = false # managed by char manager

@export var max_health: float = 50.0
var health: float = max_health :
	set(value):
		health = _on_health_change(value)
	get:
		return health

# basic atk
@export var max_ammo: int = 9
var ammo: int = max_ammo :
	set(value):
		ammo = _on_ammo_change(value)
	get:
		return ammo

# ultimate
@export var max_charge: float = 100
var charge: float

@export var charge_rate: float = 60
# EXPORT VARS, SO CHANGE THEM IN THE EDITOR!!!!

func _ready() -> void:
	skill_tree.hide()
	health = max_health
	ammo = max_ammo
	charge = 0

func _process(_delta: float) -> void:
	if !enabled:
		if skill_tree.visible:
			skill_tree.hide()
		return
	
	if Input.is_action_just_pressed("shop_key"):
		skill_tree.visible = !skill_tree.visible
	PlayerInfo.displayed_charge = charge

func _on_ammo_change(new_ammo: int) -> int:
	if enabled:
		PlayerInfo.on_ammo_changed.emit(new_ammo)
	return new_ammo #NOTE

func _on_health_change(new_health: float) -> float:
	if enabled:
		PlayerInfo.on_health_changed.emit(new_health)
	return new_health # NOTE

func update_player_info() -> void:
	# make sure that nothing changed
	PlayerInfo.on_ammo_changed.emit(ammo)
	PlayerInfo.on_health_changed.emit(health)
	PlayerInfo.on_max_changed.emit(max_ammo, max_health, max_charge)

#region Transfer: (AM) > CM > Player
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
