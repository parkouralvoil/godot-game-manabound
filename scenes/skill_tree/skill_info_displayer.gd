extends Control

@onready var sprite: Sprite2D = $Sprite2D
@onready var skill_name: Label = $VBoxContainer/Label_name
@onready var skill_desc: Label = $VBoxContainer/Label_desc
@onready var buy_button: Button = $Buy_Button

var selected_node: SkillNode

func _ready() -> void:
	skill_name.text = ""
	skill_desc.text = ""
	sprite.texture = null
	if buy_button:
		buy_button.hide()

func show_selected_skill(_node: SkillNode) -> void:
	if _node:
		selected_node = _node
		skill_name.text = selected_node.skill_name
		skill_desc.text = selected_node.skill_desc
		sprite.texture = selected_node.texture_normal
		sprite.flip_h = selected_node.flip_h
		
		if !selected_node.root:
			buy_button.disabled = !selected_node.see_if_can_buy()
			buy_button.show()
		else:
			buy_button.hide()

func _on_buy_button_pressed() -> void:
	if selected_node:
		selected_node.attempt_buy()
