extends PanelContainer
class_name SkillInfoClass

signal buy_button_pressed

var _current_node: SkillTreeNode = null
var allow_buy: bool = false

@onready var icon: TextureRect = $MarginContainer/VBox/SkillIcon
@onready var skill_name: Label = $MarginContainer/VBox/name
@onready var skill_desc: Label = $MarginContainer/VBox/ScrollContainer/description

@onready var buy_details: VBoxContainer = $MarginContainer/VBox/VBox
@onready var skill_lvl: Label = $MarginContainer/VBox/VBox/lvl
@onready var skill_cost: Label = $MarginContainer/VBox/VBox/cost
@onready var buy_button: Button = $MarginContainer/VBox/VBox/Buy_Button
@onready var tip_station: Label = $MarginContainer/VBox/requires_station

func _ready() -> void:
	## show first node's info instead
	#skill_name.text = ""
	#skill_desc.text = ""
	#icon.texture = null
	skill_lvl.hide()
	skill_cost.hide()
	buy_button.hide()
	hide()


func show_selected_skill(node_button: SkillTreeNodeButton) -> void:
	show()
	if not node_button:
		return
	
	icon.texture = node_button.texture_normal
	icon.flip_h = node_button.flip_h
	
	_current_node = node_button.stree_node
	if _current_node.lvl == _current_node.max_lvl:
		tip_station.hide()
	elif not allow_buy:
		buy_details.hide()
		tip_station.show()
	else:
		buy_details.show()
		tip_station.hide()
	_update_displayed_info()


func _update_displayed_info() -> void:
	if not _current_node:
		return
		
	var node: SkillTreeNode = _current_node
	skill_name.text = node.name
	skill_desc.text = node.description
	skill_lvl.text = "Level: %d/%d" % [node.lvl, node.max_lvl]
	skill_cost.text = "Mana Orbs Cost: %d" % node.cost
	
	if node.lvl < node.max_lvl:
		skill_lvl.show()
		skill_cost.show()
		buy_button.show()
		buy_button.text = "Unlock" if node.lvl == 0 else "Upgrade"
	elif node.max_lvl == 0: #info node
		skill_lvl.hide()
		skill_cost.hide()
		buy_button.hide()
	else:
		skill_lvl.show()
		skill_cost.show()
		skill_cost.text = "Mana Orbs Cost: ---"
		buy_button.show()
		buy_button.text = "Level Max"
		buy_button.disabled = true
		buy_button.set_pressed_no_signal(false)


func _on_buy_button_pressed() -> void:
	buy_button_pressed.emit()
	_update_displayed_info()
