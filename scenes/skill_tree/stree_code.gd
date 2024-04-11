extends CanvasLayer
class_name SkillTree

var selected_node: SkillNode = null:
	set(value):
		selected_node = value
		skill_info.show_selected_skill(value)

@onready var skill_info: Control = $Control/Skill_Info
@onready var root_node: SkillNode = $Control/Root

var BasicAtk_array: Array[SkillNode] = []
var Ult_array: Array[SkillNode] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	selected_node = null
	for child in root_node.get_children():
		if child is SkillNode:
			if child.is_in_group("skillnode_BasicAtk"):
				BasicAtk_preorder(child)
			else:
				Ult_preorder(child)


func BasicAtk_preorder(node: SkillNode) -> void:
	BasicAtk_array.append(node)
	
	for child_node in node.get_children():
		if child_node is SkillNode:
			BasicAtk_preorder(child_node)


func Ult_preorder(node: SkillNode) -> void:
	Ult_array.append(node)
	
	for child_node in node.get_children():
		if child_node is SkillNode:
			Ult_preorder(child_node)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("esc") and visible:
		unpause()


func _on_exit_button_button_down() -> void:
	unpause()

func unpause() -> void:
	var parent := get_parent()
	if parent.has_method("stats_update"):
		parent.stats_update()
	hide()
	get_tree().paused = false
