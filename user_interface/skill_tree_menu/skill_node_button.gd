extends TextureButton
class_name SkillTreeNodeButton

signal node_pressed(node: SkillTreeNode)

@export_category("Toggle this on root node")
@export var line_update: bool = false:
	set(value):
		line_update = value
		update_lines()

## THESE INFO ARE NOW STORED in the node class, assigned by the generic stree
var stree_node: SkillTreeNode:
	set(val):
		stree_node = val
		if stree_node:
			stree_node.node_updated.connect(update_node_info)
		update_node_info()

#@onready var indicator: ColorRect = $Indicator
@onready var label_lvl: Label = $lvl
@onready var label_cost: Label = $PanelContainer/cost
@onready var line_2D: Line2D = $Line2D
@onready var indicator: ColorRect = $Indicator ## ideally i just have a lock symbol

func _ready() -> void:
	update_lines()
	#get_viewport().size_changed.connect(update_lines)
	visibility_changed.connect(update_lines)
	pressed.connect(_on_pressed)


func update_lines() -> void:
	_fix_child_nodes_positions()
	for child in get_children():
		if child is TextureButton:
			child.update_lines()
	
	if get_parent() is TextureButton:
		var parent: TextureButton = get_parent()
		line_2D.points[0] = (global_position + size/2)
		line_2D.points[1] = (parent.global_position + size/2)


func _fix_child_nodes_positions() -> void:
	var node_array: Array[TextureButton] = []
	var x_offset: float = -50 if get_parent() is TextureButton else -105
	var y_offset: float = 110
	
	for node in get_children():
		if node is TextureButton:
			node_array.append(node)
	
	if node_array.size() > 1:
		y_offset = 90
	var pos_x: float = x_offset * (node_array.size() - 1)
	
	for i in range(node_array.size()):
		node_array[i].position = Vector2(pos_x + (x_offset * -2 * i), y_offset)


func update_node_info() -> void:
	set_indicator_color()
	label_lvl.text = "%d/%d" % [stree_node.lvl, stree_node.max_lvl]
	
	if stree_node.lvl < stree_node.max_lvl:
		label_cost.text = "Cost: %d" % [stree_node.cost]
	else:
		label_cost.hide()
		label_cost.text = "Cost: ---"
	
	if stree_node.max_lvl == 0: ## info node
		label_lvl.hide()


func set_indicator_color() -> void:
	var white := Color(1, 1, 1, 0) ## already bought
	var gray := Color(0, 0, 0, 0.2) ## unlocked
	var dark := Color(0, 0, 0, 0.85) ## locked
	if not stree_node.parent: ## root node
		indicator.color = white
		#print(stree_node.name)
	else:
		if stree_node.active:
			indicator.color = white
			line_2D.default_color = Color(1, 1, 0.25)
		elif stree_node.parent.active:
			indicator.color = gray
		else:
			indicator.color = dark


func _on_pressed() -> void:
	node_pressed.emit(self) ## pass the button to Stree scene which will refer to the model it has
