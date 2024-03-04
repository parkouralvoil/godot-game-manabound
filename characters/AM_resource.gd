extends Resource
class_name AM_resource

@export_category("basic atk: Base")
@export var bullet_speed: int = 400
@export var base_dmg_projectile_1: int = 5
@export var base_dmg_projectile_2: int = 0
@export var max_distance: int = 300

@export_category("basic atk: Scaling")
@export var scale_dmg_projectile_1: int = 0
@export var scale_dmg_projectile_2: int = 5

@export_category("ult: Base")
@export var ult_bullet_speed: int = 600
@export var ult_dmg_tier1: int = 20
@export var ult_dmg_tier2: int = 25
@export var ult_max_distance: int = 1000

@export_category("ult: Scaling")
@export var scale_ult_dmg_tier1: int = 20
@export var scale_ult_dmg_tier2: int = 25

@export_category("Other")
# each char only has a specific upgrade for one stat, to ease building
@export var scale_stat: int = 2
@export var scale_charge_rate: int = 25
