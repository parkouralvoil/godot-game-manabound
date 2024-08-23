extends Control
class_name SkillTreeMenu

##@onready var stree_knight: Control = $Stree_Knight
## manager shouldnt have to know which stree this is, it just has to be a generic stree
const inventory: PlayerInventory = preload("res://resources/data/player_inventory/player_inventory.tres")

@onready var stree_holder: AspectRatioContainer = $MarginContainer/HBoxContainer/StreeHolder
@onready var skill_info: SkillInfoClass = $MarginContainer/HBoxContainer/MarginContainer/Skill_Info
@onready var orbs_display: Label = $OrbsDisplay
@onready var current_stree: SkillTreeSpecific = null

var stree_array: Array[SkillTreeSpecific]


func initialize_stree_menu() -> void:
	assert(stree_array[0], "missing stree at scene: %s" % name)
	current_stree = stree_array[0] ## NOTE: ORDER OF ARRAY IS IMPORTANT, 
	## it must align with order of characters in the team


func _ready() -> void:
	for child in stree_holder.get_children():
		if not child is SkillTreeSpecific:
			continue
		var stree: SkillTreeSpecific = child
		stree.tree_button_pressed.connect(retrieve_stree_info)
		stree_array.append(stree)
		stree.hide()
	
	initialize_stree_menu()
	
	skill_info.buy_button_pressed.connect(stree_perform_buy)
	visibility_changed.connect(retrieve_stree_info.bind(current_stree.root_node_button, current_stree))
	current_stree.show()

func retrieve_stree_info(_button: SkillTreeNodeButton, _stree: SkillTreeSpecific) -> void:
	current_stree = _stree
	current_stree.call_update_node_info()
	skill_info.show_selected_skill(_button)
	orbs_display.text = "Mana Orbs: %d" % inventory.mana_orbs
	
	var node: SkillTreeNode = _button.stree_node
	skill_info.buy_button.disabled = not _stree.skill_tree_model.check_if_can_buy(node)


func stree_perform_buy() -> void:
	if not current_stree: ## HACK
		OS.alert("Stree is somehow not present in (stree_perform_buy) inside %s" % name)
	
	current_stree.call_attempt_buy_node()
	orbs_display.text = "Mana Orbs: %d" % inventory.mana_orbs


func _switch_stree(stree: SkillTreeSpecific) -> void:
	for t in stree_array:
		if not t == stree:
			t.hide()
	stree.show()
	retrieve_stree_info(stree.root_node_button, stree)
	current_stree = stree


func show_specific_menu(index: int) -> String:
	if index >= 0 and index < 3:
		_switch_stree(stree_array[index])
	else:
		OS.alert("Called (show_specific_menu) on %s with OOB index: %d" % [name, index])
	return stree_array[index].name
