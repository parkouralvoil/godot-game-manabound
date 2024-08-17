extends Marker2D

@onready var level: LevelManager = owner
@onready var line_interact: Line2D = $Line2D_interact
@onready var label_container: CenterContainer = $CenterContainer
@onready var label: Label = $CenterContainer/Label

var player_nearby: bool = false
var is_open: bool = false
var pressed: bool = false

var closed_text: String = "ENEMIES STILL ALIVE!"
var open_text: String = "Press E to enter"

var red_opaque: Color = Color(1, 0.5, 0.5, 1)

var green_fade: Color = Color(0.3, 0.8, 0.3, 0.2)
var green_opaque: Color = Color(0.4, 1, 0.4, 1)

func _ready() -> void:
	line_interact.visible = false
	label_container.visible = false
	$opened_door.hide()

func _physics_process(_delta: float) -> void:
	
	if open or player_nearby:
		line_interact.points[1] = (EnemyAiManager.player_position - position)
	if player_nearby and Input.is_action_just_pressed("interact") and is_open and not pressed:
		line_interact.hide()
		EventBus.go_next_lvl.emit(level)
		pressed = true


func open() -> void:
	is_open = true
	line_interact.visible = true
	line_interact.default_color = green_opaque if player_nearby else green_fade
	$opened_door.show()


func _on_area_2d_playercheck_body_entered(body: Node2D) -> void:
	if body is Player:
		player_nearby = true
		line_interact.visible = true
		line_interact.default_color = red_opaque if not is_open else green_opaque
		label_container.visible = true
		label.text = closed_text if not is_open else open_text


func _on_area_2d_playercheck_body_exited(body: Node2D) -> void:
	if body is Player:
		player_nearby = false
		line_interact.visible = false if not is_open else true
		line_interact.default_color = red_opaque if not is_open else green_fade
		label_container.visible = false
		label.text = closed_text if not is_open else open_text
