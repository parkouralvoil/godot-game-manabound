extends Control
class_name SkillTreeMenu

## DYNAMICALLY ADDS CHILDREN TO "Skill_Info

## external data
var inventory: PlayerInventory = preload("res://resources/data/player_inventory/player_inventory.tres") ## for mana orbs

## internal data
var stree_array: Array[SkillTreeSpecific]

@onready var stree_holder: Container = %StreeHolder
@onready var skill_info: SkillInfoClass = %Skill_Info
@onready var orbs_display: Label = $OrbsDisplay
@onready var current_stree: SkillTreeSpecific = null

func initialize_stree_menu(_selected_team_info: SelectedTeamInfo) -> void:
	var char_resource_array := _selected_team_info.char_data_array
	for char_resource in char_resource_array:
		var stree: SkillTreeSpecific = char_resource.skill_tree_scene.instantiate()
		stree.tree_button_pressed.connect(retrieve_stree_info)
		stree.name = "%s Skill Tree" % char_resource.char_name
		stree_array.append(stree)
		stree_holder.add_child(stree)
		stree.hide()
	
	current_stree = stree_array[0]
	
	skill_info.buy_button_pressed.connect(stree_perform_buy)
	visibility_changed.connect(retrieve_stree_info.bind(current_stree.root_node_button, current_stree))
	current_stree.show()
	
	skill_info.allow_buy = false ## NOTE: this menu cannot upgrade stree

#func _ready() -> void:
	#for child in stree_holder.get_children():
		#if not child is SkillTreeSpecific:
			#continue
		#var stree: SkillTreeSpecific = child
		#stree.tree_button_pressed.connect(retrieve_stree_info)
		#stree_array.append(stree)
		#stree.hide()
	#
	#skill_info.buy_button_pressed.connect(stree_perform_buy)
	#visibility_changed.connect(retrieve_stree_info.bind(current_stree.root_node_button, current_stree))
	#current_stree.show()
	#
	#skill_info.allow_buy = false ## NOTE: this menu cannot upgrade stree

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
