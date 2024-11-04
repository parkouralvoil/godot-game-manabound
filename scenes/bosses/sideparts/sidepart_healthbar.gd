extends ProgressBar
class_name SidepartRailgunHealthbar

@onready var e: BaseEnemy = get_parent().get_parent()


func _ready() -> void:
	e.health_changed.connect(update)

func update(new_health: float) -> void:
	value = new_health * 100 / e.max_health
