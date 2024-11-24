extends Node2D
class_name MainHub_SignBoard

var player_nearby: bool = false
var pressed: bool = false

@export var info_text: String = "Press E to select an expedition"

@onready var label: Label = $Label
@onready var interactable: Interactable = $Interactable

func _ready() -> void:
	interactable.set_color(self)
	interactable.arrow.show()
	label.visible = false
	label.text = info_text
	EventBus.interactable_detected.connect(toggle_info)


func try_interact() -> void:
	if player_nearby and not pressed: ## to avoid spamming this
		EventBus.interacted_signboard.emit()
		pressed = true
		await get_tree().physics_frame
		pressed = false



func toggle_info(event_bus_interactable: Interactable) -> void:
	if event_bus_interactable == interactable:
		player_nearby = true
		label.visible = true
	else:
		player_nearby = false
		label.visible = false
