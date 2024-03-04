extends Marker2D

@export_file("*.tscn") var next_level: String

@onready var line_interact: Line2D = $Line2D_interact
@onready var label_pressE: Label = $Label_pressE

var player_nearby: bool = false

func _ready() -> void:
	line_interact.visible = false
	label_pressE.visible = false

func _process(delta: float) -> void:
	if player_nearby:
		line_interact.points[1] = (EnemyAiManager.player_position - position)
	if player_nearby and Input.is_action_just_pressed("interact"):
		EventBus.scene_transition.emit(next_level)


func _on_area_2d_playercheck_body_entered(body: Node2D) -> void:
	if body is Player:
		player_nearby = true
		line_interact.visible = true
		label_pressE.visible = true


func _on_area_2d_playercheck_body_exited(body: Node2D) -> void:
	if body is Player:
		player_nearby = false
		line_interact.visible = false
		label_pressE.visible = false
