extends Control

@onready var stree_knight: Control = $Stree_Knight
@onready var skill_info: SkillInfoClass = $Skill_Info


func _process(_delta: float) -> void:
	if stree_knight.selected_node:
		skill_info.selected_node = stree_knight.selected_node


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc") and visible:
		unpause()


func unpause() -> void:
	## Pausing and Unpausing should be handled by UI manager
	hide()
	get_tree().paused = false


func _on_exit_button_pressed() -> void:
	unpause()
