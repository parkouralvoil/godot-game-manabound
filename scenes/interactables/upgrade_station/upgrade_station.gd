extends Sprite2D
class_name UpgradeStation

@export var PlayerInfo: PlayerInfoResource

var player_nearby: bool = false

@onready var tip: Label = $Tip
@onready var interactable: Interactable = $Interactable

## uses player info

func _ready() -> void:
	interactable.set_color(self)
	tip.hide()
	EventBus.interactable_detected.connect(_on_interactable_detected)


func _unhandled_key_input(_event: InputEvent) -> void:
	if EventBus.interacting and player_nearby:
		EventBus.interacted_upgraded_station.emit()
		EventBus.interacting = false


func _on_interactable_detected(event_bus_interactable: Interactable) -> void:
	if event_bus_interactable == interactable:
		tip.show()
		player_nearby = true
	else:
		tip.hide()
		player_nearby = false
