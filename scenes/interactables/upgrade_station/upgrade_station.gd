extends Sprite2D
class_name UpgradeStation

var player_nearby: bool = false

@onready var tip: Label = $Tip
@onready var interactable: Interactable = $Interactable

## uses player info

func _ready() -> void:
	interactable.set_color(self)
	tip.hide()
	EventBus.interactable_detected.connect(_on_interactable_detected)
	interactable.set_opens_ui_true()


func try_interact() -> void:
	if player_nearby:
		EventBus.interacted_upgraded_station.emit()


func _on_interactable_detected(event_bus_interactable: Interactable) -> void:
	if event_bus_interactable == interactable:
		tip.show()
		player_nearby = true
	else:
		tip.hide()
		player_nearby = false
