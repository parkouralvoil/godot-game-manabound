extends Node2D

@onready var skill_tree: CanvasLayer = $SkillTree

func _ready():
	skill_tree.hide()

func _process(delta):
	if Input.is_action_just_pressed("shop_key"):
		skill_tree.visible = !skill_tree.visible
