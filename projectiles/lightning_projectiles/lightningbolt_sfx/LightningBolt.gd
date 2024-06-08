extends Node2D
class_name LightningSFX
## SOURCE: https://github.com/Geminimax/Godot-2d-Lightning
var goal_point : Vector2 = Vector2(100,100)
@export var line_width : float = 1: set = set_width
@onready var lightning : Array = get_children()

func _ready():
	set_width(line_width)
	
func _process(_delta) -> void:
	for child in lightning:
		child.goal_point =  goal_point
	
func start_emitting() -> void:
	for child in lightning:
		child.emitting = true

func stop_emitting() -> void:
	for child in lightning:
		if child is LightningLine:
			child.emitting = false

func set_width(amount: int) -> void:
	line_width = amount
	for child in get_children():
		child.set_line_width(line_width)
