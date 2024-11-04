extends Node2D
class_name RailgunBoss ## this is not an enemy, its more of a boss holder / enemy holder

enum PHASE {
	ONE,
	TWO,
}

@export var Phase1_HP: float = 4000
@export var Phase2_HP: float = 500 ## will update stats.HP of main gun to have this

var current_MAX_HP: float = Phase1_HP
var current_HP: float = Phase1_HP:
	set(val):
		current_HP = val
		update_healthbar()
var current_phase: PHASE = PHASE.ONE
var boss_HP_bar: ProgressBar:
	set(val):
		boss_HP_bar = val
		if val:
			boss_HP_bar.value = boss_HP_bar.max_value

@onready var main_boss_hurtbox: HurtboxComponent = $MainGun/BossHurtbox

func initialize_phase_one() -> void:
	main_boss_hurtbox.monitorable = false


func _ready() -> void:
	initialize_phase_one()
	EventBus.boss_fight_started.emit(self)  ## healthbar is assigned thru this, tho kinda spaghetty


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func take_boss_damage(damage: float):
	current_HP = max(current_HP - damage, 0)


func update_healthbar() -> void:
	if boss_HP_bar:
		boss_HP_bar.value = (current_HP/current_MAX_HP) * boss_HP_bar.max_value
