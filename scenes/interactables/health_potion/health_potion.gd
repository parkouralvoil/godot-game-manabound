extends Sprite2D
class_name HealthPotionDrop

@export var PlayerInfo: PlayerInfoResource
@export var heal_sfx: AudioStream

var player_nearby: bool = false

@onready var tip: Label = $Tip
@onready var interactable: Interactable = $Interactable

## uses player info

func _ready() -> void:
	add_to_group("interactable")
	tip.hide()
	EventBus.interactable_detected.connect(_on_interactable_detected)


func try_interact() -> void: ## called by interactable
	if player_nearby:
		SoundPlayer.play_sound(heal_sfx, -15)
		PlayerInfo.drank_hp_potion.emit()
		queue_free()


func _on_interactable_detected(event_bus_interactable: Interactable) -> void:
	if event_bus_interactable == interactable:
		tip.show()
		player_nearby = true
	else:
		tip.hide()
		player_nearby = false
