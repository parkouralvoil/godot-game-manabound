extends Node2D
class_name ExitDoor

signal local_exit_door_interacted

var player_nearby: bool = false
var is_open: bool = false
var pressed: bool = false


@export var starts_open: bool ## for rest rooms/ main hub
@export var closed_text: String = "ENEMIES STILL ALIVE!"
@export var open_text: String = "Press E to enter"

var red_opaque: Color = Color(1, 0.5, 0.5, 1)

var green_fade: Color = Color(0.3, 0.8, 0.3, 0.2)
var green_opaque: Color = Color(0.4, 1, 0.4, 1)

@onready var label: Label = $Label
@onready var opened_door: Sprite2D = $opened_door
@onready var interactable: Interactable = $Interactable

func _ready() -> void:
	interactable.set_color(self)
	interactable.arrow.hide()
	label.visible = false
	opened_door.hide()
	EventBus.interactable_detected.connect(toggle_info)
	if starts_open:
		open()


func _input(event: InputEvent) -> void:
	if EventBus.interacting and player_nearby:
		if is_open and not pressed:
			#line_interact.hide()
			local_exit_door_interacted.emit()
			pressed = true
		EventBus.interacting = false


func open() -> void:
	is_open = true
	interactable.arrow.show()
	#line_interact.visible = true
	#line_interact.default_color = green_opaque if player_nearby else green_fade
	opened_door.show()


func toggle_info(event_bus_interactable: Interactable) -> void:
	if event_bus_interactable == interactable:
		player_nearby = true
		#line_interact.visible = true
		#line_interact.default_color = red_opaque if not is_open else green_opaque
		label.visible = true
		label.text = closed_text if not is_open else open_text
	else:
		player_nearby = false
		#line_interact.visible = false if not is_open else true
		#line_interact.default_color = red_opaque if not is_open else green_fade
		label.visible = false
		label.text = closed_text if not is_open else open_text
