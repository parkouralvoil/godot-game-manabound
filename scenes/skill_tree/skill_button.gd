extends TextureButton
class_name SkillNode 

@onready var panel: Panel = $Panel
@onready var VBox: VBoxContainer = $VBox

@onready var label_lvl: Label = $VBox/Label_lvl
@onready var label_cost: Label = $VBox/Label_cost

@onready var line_2D: Line2D = $Line2D

@export var root: bool = false

@export var default_cost: int = 100
@onready var cost: int = default_cost

@export var max_level: int = 3

@export var skill_name: String
@export_multiline var skill_desc: String

var level: int = 0:
	set(value):
		level = value

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	get_viewport().size_changed.connect(update_lines)
	visibility_changed.connect(update_lines)
	
	set_deferred("size", Vector2(50, 50))
	
	if root:
		panel.hide()
		VBox.hide()
		level = max_level
		line_2D.default_color = Color(1, 1, 0.25)
		#enable_child_buttons()
	else:
		label_cost.text = "Cost: " + str(cost)
	
	update_lvl_and_cost()
	update_lines() 

func update_lines() -> void:
	if get_parent() is SkillNode:
		line_2D.points[0] = (global_position + size/2)
		line_2D.points[1] = (get_parent().global_position + size/2)

func _on_pressed() -> void:
	var stree: SkillTree = owner
	if stree:
		stree.selected_node = self
	if root:
		return
	
	var parent_node: SkillNode = get_parent()
	if PlayerInfo.mana_orbs >= cost and parent_node.level > 0 and level < max_level:
		PlayerInfo.mana_orbs -= cost
		level = min(level+1, max_level)
		cost = default_cost + (default_cost/2 * level)
		update_lvl_and_cost()
		
		panel.hide()
		line_2D.default_color = Color(1, 1, 0.25)
		#enable_child_buttons()

func update_lvl_and_cost() -> void:
	label_lvl.text = "Level: %d/%d" % [level, max_level]
	if level < max_level:
		label_cost.text = "Cost: %d" % [cost]
	else:
		label_cost.text = "Cost: ---"

#func enable_child_buttons() -> void:
	#var skills: Array[Node] = get_children()
	#for skill in skills:
		#if skill is SkillNode and level >= 1:
			#skill.disabled = false
