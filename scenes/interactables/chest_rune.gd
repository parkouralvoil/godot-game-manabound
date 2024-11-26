extends Sprite2D
class_name ChestRune


const opened: AtlasTexture = preload("res://resources/textures/interactables/chest_rune_opened.tres")

@export var rune_manager: RuneManager
@export var rune_scene: PackedScene

@export_category("For testing")
@export var is_open: bool = false

var rune: RuneData
var drop_HP_rune: bool = false ## set to true by level if level is a rest_preset


func _ready() -> void: ## JUST FOR TESTING
	#rune = rune_manager.pick_random_rune()
	if is_open:
		open_chest_rune()


func spawn_rune() -> void: ## THE RUNE DROP IS JUST FOR SHOW,
	## the chest updates inventory once it opens, thru the RuneManager
	var rune_drop: RuneCollectible = rune_scene.instantiate()
	rune_drop.texture = rune.texture
	
	add_child(rune_drop) ## chest is not gonna move anyway
	#print_debug("rune spawned: ", rune_drop.texture)
	var angle: float = RNG.random_float(75, 80)
	var dist: float = RNG.random_float(10, 20)
	var direction: Vector2 = Vector2.RIGHT
	if RNG.roll_probability(0.5):
		direction = Vector2.LEFT
	rune_drop.launch_rune_from_chest(global_position, direction, dist, angle)


func open_chest_rune() -> void:
	if not visible:
		return
	#print_debug(drop_HP_rune)
	if drop_HP_rune:
		rune = rune_manager.pick_HP_rune()
	else:
		rune = rune_manager.pick_random_rune()
	texture = opened
	if rune:
		spawn_rune()
		rune.collect_rune()
	
	## spawn a rune, rune is decided by ChestRuneManager in lvl scene


func disable_chest() -> void:
	visible = false


## how to spawn chests
"""
the lvl already has ALL the chests locations set up, (max of like 10-15)

then the lvl will disable chests to adjust the lvl to have the correct number of chest depending on cycle
"""
