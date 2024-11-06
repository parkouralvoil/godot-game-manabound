extends EnemyHealthComponent
class_name MainRailgun_Health

signal main_part_damaged

func _ready() -> void: ## IMPORTANT, to override ready of base
	pass

# Called when the node enters the scene tree for the first time.
func initialize_main_health_comp(boss_box: Container) -> void:
	box = boss_box
	assert(box)
	super._ready()


func _final_damage_received(final_dmg: float) -> void:
	main_part_damaged.emit(final_dmg)
