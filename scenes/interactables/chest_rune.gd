extends Sprite2D
class_name ChestRune


const opened: AtlasTexture = preload("res://resources/textures/interactables/chest_rune_opened.tres")


@export var is_open: bool = false


func _ready() -> void: ## JUST FOR TESTING
	if is_open:
		open_chest_rune()


func open_chest_rune() -> void:
	if not visible:
		return
	
	texture = opened
	## spawn a rune, rune is decided by ChestRuneManager in lvl scene


func disable_chest() -> void:
	visible = false


## how to spawn chests
"""
the lvl already has ALL the chests locations set up, (max of like 10-15)

then the lvl will disable chests to adjust the lvl to have the correct number of chest depending on cycle
"""
