extends Control
class_name SkillTreeSpecific

signal tree_button_pressed(button: SkillTreeNodeButton, stree: SkillTreeSpecific)

@export var skill_tree_model: SkillTreeModel

var left_node_buttons: Array[SkillTreeNodeButton] = []
var right_node_buttons: Array[SkillTreeNodeButton] = []

@onready var selected_button: SkillTreeNodeButton = null: ## need to give reference to texture of skill node
	set(value):
		selected_button = value

@onready var root_node_button: SkillTreeNodeButton = $root
@onready var left_root_button: SkillTreeNodeButton = $root/left_root
@onready var right_root_button: SkillTreeNodeButton = $root/right_root

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	root_node_button.node_pressed.connect(button_selected)
	root_node_button.stree_node = skill_tree_model.root_node
	
	## appends buttons to the arrays
	traverse_tree(left_root_button, left_node_buttons)
	traverse_tree(right_root_button, right_node_buttons)
	
	## gives buttons their referenced nodes
	for i in range(left_node_buttons.size()):
		var node: SkillTreeNode = skill_tree_model.left_nodes[i]
		left_node_buttons[i].node_pressed.connect(button_selected)
		left_node_buttons[i].stree_node = node
		
		
	for i in range(right_node_buttons.size()):
		right_node_buttons[i].node_pressed.connect(button_selected)
		right_node_buttons[i].stree_node = skill_tree_model.right_nodes[i]
	
	## gives nodes their parents based on arrangement of buttons (parent informs the child)
	assign_parent(left_root_button)
	assign_parent(right_root_button)
	call_update_node_info()

func traverse_tree(node: SkillTreeNodeButton, arr: Array[SkillTreeNodeButton]) -> void:
	arr.append(node)
	for child in node.get_children():
		if child is SkillTreeNodeButton:
			traverse_tree(child, arr)


func assign_parent(node_button: SkillTreeNodeButton) -> void:
	for child in node_button.get_children():
		if child is SkillTreeNodeButton:
			var child_node: SkillTreeNode = child.stree_node
			child_node.parent = node_button.stree_node
			assign_parent(child)


func button_selected(button: SkillTreeNodeButton) -> void:
	tree_button_pressed.emit(button, self)
	selected_button = button
	## selected tree = self
	## the actual purchasing will be confirmed by SkillTreeManager, who call a function here


func call_attempt_buy_node() -> void:
	skill_tree_model.attempt_buy_node(selected_button.stree_node)
	call_update_node_info()


func call_update_node_info() -> void:
	for node in left_node_buttons:
		node.update_node_info()
	for node in right_node_buttons:
		node.update_node_info()
