extends Node2D
class_name ExitDoor

signal local_exit_door_interacted

@export var starts_open: bool ## for rest rooms/ main hub
@export var closed_text: String = "ENEMIES STILL ALIVE!"
@export var open_text: String = "Enter next level"
@export_category("Textures")
## by default it's city door
@export var door_texture: Texture

var player_nearby: bool = false
var is_open: bool = false
var pressed: bool = false

@onready var label: Label = $Label
@onready var opened_door: Sprite2D = $opened_door
@onready var closed_door: Sprite2D = $closed_door
@onready var interactable: Interactable = $Interactable

func _ready() -> void:
	interactable.set_color(self)
	interactable.arrow.hide()
	label.visible = false
	opened_door.hide()
	EventBus.interactable_detected.connect(toggle_info)
	interactable.set_opens_ui_true()
	if door_texture:
		opened_door.texture.atlas = door_texture
		closed_door.texture.atlas = door_texture
		
	if starts_open:
		open()


func try_interact() -> void:
	if player_nearby:
		if is_open and not pressed: ## to avoid spamming this
			local_exit_door_interacted.emit()
			pressed = true
			await get_tree().physics_frame
			pressed = false

func open() -> void:
	is_open = true
	interactable.arrow.show()
	opened_door.show()


func toggle_info(event_bus_interactable: Interactable) -> void:
	if event_bus_interactable == interactable:
		player_nearby = true
		label.visible = true
		label.text = closed_text if not is_open else open_text
	else:
		player_nearby = false
		label.visible = false
		label.text = closed_text if not is_open else open_text
