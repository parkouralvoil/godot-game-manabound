extends SkillTreeMenu
class_name UpgradeStreeMenu

signal exit_menu

func initialize_stree_menu(_selected_team_info: SelectedTeamInfo) -> void:
	var char_resource_array := _selected_team_info.char_data_array
	for char_resource in char_resource_array:
		var stree: SkillTreeSpecific = char_resource.skill_tree_scene.instantiate()
		stree.tree_button_pressed.connect(retrieve_stree_info)
		stree.name = "%s" % char_resource.char_name
		stree_array.append(stree)
		stree_holder.add_child(stree)
		stree.hide()
	
	current_stree = stree_array[0]
	
	skill_info.buy_button_pressed.connect(stree_perform_buy)
	visibility_changed.connect(retrieve_stree_info.bind(current_stree.root_node_button, current_stree))
	current_stree.show()
	
	skill_info.allow_buy = true

func _on_exit_button_pressed() -> void:
	exit_menu.emit()


func _on_stree_holder_tab_changed(tab: int) -> void:
	_switch_stree(stree_array[tab])
