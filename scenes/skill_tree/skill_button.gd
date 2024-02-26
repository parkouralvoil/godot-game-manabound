extends TextureButton
class_name SkillNode 

@onready var panel: Panel = $Panel
@onready var margin_container: MarginContainer = $MarginContainer
@onready var label: Label = $MarginContainer/Label
@onready var line_2D: Line2D = $Line2D

@export var root: bool = false

var level: int = 0:
	set(value):
		level = value
		label.text = str(level) + "/3"

func _ready() -> void:
	if root:
		size = Vector2.ZERO
		panel.hide()
		label.hide()
		label.hide()
		level = 3
		enable_child_buttons()
	else:
		size = Vector2(60, 60)
		disabled = true
		panel.size = size
	if get_parent() is SkillNode:
		line_2D.add_point(global_position + size/2)
		line_2D.add_point(get_parent().global_position + size/2)

func _on_pressed() -> void:
	level = min(level+1, 3)
	panel.show_behind_parent = true
	enable_child_buttons()

func enable_child_buttons() -> void:
	line_2D.default_color = Color(1, 1, 0.25)
	var skills: Array[Node] = get_children()
	for skill in skills:
		if skill is SkillNode and level >= 1:
			skill.disabled = false
