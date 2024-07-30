extends Node2D
class_name LightningSFX
## SOURCE: https://github.com/Geminimax/Godot-2d-Lightning

var goal_point : Vector2 = Vector2(100,100)

@export var line_width: float = 1.0: 
	set = set_width

@onready var lightning: Array[Node] = get_children()

func _ready() -> void:
	set_width(line_width)


func _process(_delta: float) -> void:
	for child in lightning:
		if not child is LightningLine:
			continue
		var l: LightningLine = child
		l.goal_point = goal_point


func start_emitting() -> void:
	for child in lightning:
		if not child is LightningLine:
			continue
		var l: LightningLine = child
		l.emitting = true


func stop_emitting() -> void:
	for child in lightning:
		if not child is LightningLine:
			continue
		var l: LightningLine = child
		l.emitting = false


func set_width(amount: float) -> void:
	line_width = amount
	for child in get_children():
		if not child is LightningLine:
			continue
		var l: LightningLine = child
		l.set_line_width(line_width)
