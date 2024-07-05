extends TextureButton
class_name SkillNode 

@export var PlayerInfo: PlayerInfoResource

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
	fix_child_nodes_positions()

func update_lines() -> void:
	if get_parent() is SkillNode:
		line_2D.points[0] = (global_position + size/2)
		line_2D.points[1] = (get_parent().global_position + size/2)

func _on_pressed() -> void:
	var stree: SkillTree = owner
	if stree:
		stree.selected_node = self

func attempt_buy() -> void:
	if root:
		return
	if see_if_can_buy():
		PlayerInfo.mana_orbs -= cost
		level = min(level+1, max_level)
		cost = default_cost + (default_cost/2 * level)
		update_lvl_and_cost()
		
		panel.hide()
		line_2D.default_color = Color(1, 1, 0.25)
		#enable_child_buttons()

func see_if_can_buy() -> bool:
	var parent_node: SkillNode = get_parent()
	if PlayerInfo.mana_orbs >= cost and parent_node.level > 0 and level < max_level:
		return true
	else:
		return false

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

func fix_child_nodes_positions() -> void:
	var node_array: Array[SkillNode] = []
	var initial_x: float = -50
	if root: initial_x = -100
	
	for node in get_children():
		if node is SkillNode:
			node_array.append(node)
	
	var pos_x: float = initial_x * (node_array.size() - 1)
	
	for i in range(node_array.size()):
		node_array[i].position = Vector2(pos_x + (initial_x*-2*i), 85)
