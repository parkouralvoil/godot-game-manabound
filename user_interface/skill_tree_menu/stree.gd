extends Control

@export var skill_tree_model: SkillTreeModel
@export_category("Nodes") ## since the arrangement of the nodes arent consistent
var left_node_buttons: Array[SkillTreeNodeButton] = []
var right_node_buttons: Array[SkillTreeNodeButton] = []

@onready var selected_node: SkillTreeNode = null:
	set(value):
		selected_node = value

@onready var root_node_button: SkillTreeNodeButton = $root
@onready var left_root_button: SkillTreeNodeButton = $root/left_root
@onready var right_root_button: SkillTreeNodeButton = $root/right_root


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	root_node_button.node_pressed.connect(button_selected)
	root_node_button.stree_node = skill_tree_model.root_node
	
	traverse_tree(left_root_button, left_node_buttons)
	traverse_tree(right_root_button, right_node_buttons)
	
	
	for i in range(left_node_buttons.size()):
		left_node_buttons[i].node_pressed.connect(button_selected)
		left_node_buttons[i].stree_node = skill_tree_model.left_nodes[i]
		
	for i in range(right_node_buttons.size()):
		right_node_buttons[i].node_pressed.connect(button_selected)
		right_node_buttons[i].stree_node = skill_tree_model.right_nodes[i]


func traverse_tree(node: SkillTreeNodeButton, arr: Array[SkillTreeNodeButton]) -> void:
	arr.append(node)
	for child in node.get_children():
		if child is SkillTreeNodeButton:
			traverse_tree(child, arr)


func button_selected(button: SkillTreeNodeButton) -> void:
	selected_node = button.stree_node
	## selected tree = self
	## the actual purchasing will be confirmed by SkillTreeManager, who call a function here


func call_attempt_buy_node() -> void:
	skill_tree_model.attempt_buy_node(selected_node)
