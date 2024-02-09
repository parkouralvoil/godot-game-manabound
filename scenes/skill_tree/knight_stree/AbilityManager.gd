extends Node2D
class_name AbilityManager # rename to character manager

@onready var skill_tree: CanvasLayer = $SkillTree
@onready var CM: CharacterManager = get_parent()

var enabled: bool = false # managed by char manager

var max_health: float = 50.0
var health: float = max_health

# basic atk
var max_ammo: int = 9
var ammo: int = max_ammo

# ultimate
var max_charge: float = 100
var charge: float = 0

var charge_rate: float = 75

func _ready():
	skill_tree.hide()

func _process(delta):
	if !enabled:
		charge = 0
		if skill_tree.visible:
			skill_tree.hide()
		return
	
	if Input.is_action_just_pressed("shop_key"):
		skill_tree.visible = !skill_tree.visible
	update_player_info()

func update_stats():
	pass

func update_player_info():
	PlayerInfo.displayed_ammo = ammo
	PlayerInfo.displayed_max_ammo = max_ammo
	PlayerInfo.displayed_health = health
	PlayerInfo.displayed_max_health = max_health
	PlayerInfo.displayed_charge = charge
	PlayerInfo.displayed_max_charge = max_charge

#region Transfer: (AM) > CM > Player
func set_player_velocity(velocity: Vector2):
	if CM:
		CM.set_player_velocity(velocity)

func apply_player_cam_shake(strength: int):
	if CM:
		CM.apply_player_cam_shake(strength)

func sprite_look_at(direction: Vector2):
	if CM:
		CM.sprite_look_at(direction)
#endregion
