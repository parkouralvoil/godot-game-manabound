extends Control

@onready var sprite: Sprite2D = $Sprite2D
@onready var skill_name: Label = $VBoxContainer/Label_name
@onready var skill_desc: Label = $VBoxContainer/Label_desc

func _ready() -> void:
	skill_name.text = ""
	skill_desc.text = ""
	sprite.texture = null

func show_selected_skill(selected_node: SkillNode) -> void:
	if selected_node:
		skill_name.text = selected_node.skill_name
		skill_desc.text = selected_node.skill_desc
		sprite.texture = selected_node.texture_normal
