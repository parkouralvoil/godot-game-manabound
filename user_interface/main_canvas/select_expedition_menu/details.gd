extends AspectRatioContainer
class_name ExpeditionDetails

@export var area_resource: AreaData

@onready var label_completed: Label = %completed
@onready var begin_button: Button = %BeginExpedition

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(area_resource, "missing area export")
	begin_button.pressed.connect(emit_mainhub_departed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func emit_mainhub_departed() -> void:
	EventBus.mainhub_departed.emit(area_resource)
