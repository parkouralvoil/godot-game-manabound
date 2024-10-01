extends TextureButton
class_name SkillTreeNodeButton

signal node_pressed(node: SkillTreeNode)

## THESE INFO ARE NOW STORED in the node class, assigned by the generic stree
var stree_node: SkillTreeNode:
	set(val):
		stree_node = val
		if stree_node:
			stree_node.node_updated.connect(update_node_info)
		update_node_info()

#@onready var indicator: ColorRect = $Indicator
@onready var label_lvl_panel: PanelContainer = $PanelContainer2
@onready var label_lvl: Label = $PanelContainer2/lvl
@onready var label_cost_panel: PanelContainer = $PanelContainer
@onready var label_cost: Label = $PanelContainer/cost
@onready var line_2D: Line2D = $Line2D
@onready var indicator: ColorRect = $Indicator ## ideally i just have a lock symbol

func _ready() -> void:
	visibility_changed.connect(fix_lines_pos)
	pressed.connect(_on_pressed)


#func _fix_child_nodes_positions() -> void:
	#var node_array: Array[TextureButton] = []
	#var x_offset: float = -50 if get_parent() is TextureButton else -90
	#var y_offset: float = 55 if get_parent() is TextureButton else 90
	#
	#for node in get_children():
		#if node is TextureButton:
			#node_array.append(node)
	#
	#if node_array.size() == 1:
		#y_offset = 75
	#var pos_x: float = x_offset * (node_array.size() - 1)
	#
	#for i in range(node_array.size()):
		#node_array[i].position = Vector2(pos_x + (x_offset * -2 * i), y_offset)


func update_node_info() -> void:
	set_indicator_color()
	label_lvl.text = "%d/%d" % [stree_node.lvl, stree_node.max_lvl]
	
	if stree_node.lvl < stree_node.max_lvl:
		label_cost.text = "%d" % [stree_node.cost]
		label_cost_panel.show()
	else:
		label_cost_panel.hide()
	
	if stree_node.max_lvl == 0: ## info node
		label_lvl_panel.hide()


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
			line_2D.default_color = Color(0.17, 1, 0.63)
		elif stree_node.parent.active:
			indicator.color = gray
			line_2D.default_color = Color(0.6, 0.6, 0.8)
		else:
			indicator.color = dark
			line_2D.default_color = Color(0, 0.05, 0.3)


func fix_lines_pos() -> void:
	#_fix_child_nodes_positions()
	await get_tree().process_frame
	line_2D.show()
	for child in get_children():
		if child is TextureButton:
			child.fix_lines_pos()
	
	if get_parent() is TextureButton:
		var parent: TextureButton = get_parent()
		line_2D.points[0] = (global_position + size/2)
		line_2D.points[1] = (parent.global_position + size/2)


func _on_pressed() -> void:
	node_pressed.emit(self) ## pass the button to Stree scene which will refer to the model it has
