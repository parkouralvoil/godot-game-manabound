extends Node2D
class_name RailgunBoss

enum PHASE {
	ONE,
	TWO,
}

@export var Phase1_HP: float = 5000
@export var Phase2_HP: float = 3000

var current_HP: float = Phase1_HP
var current_phase: PHASE = PHASE.ONE
var boss_HP_bar: ProgressBar

@onready var main_boss_hurtbox: HurtboxComponent = %MainBossHurtbox

func initialize_phase_one() -> void:
	main_boss_hurtbox.monitorable = false


func _ready() -> void:
	initialize_phase_one()
	EventBus.boss_fight_started.emit(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
