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
var boss_box: Container

#@onready var main_boss_hurtbox: HurtboxComponent = $MainGun/BossHurtbox
@onready var main_boss_health_comp: MainRailgun_Health = $MainGun/HealthComponent
@onready var laser_left: SidepartRailgun = $LaserLeft
@onready var laser_right: SidepartRailgun = $LaserRight
@onready var orb_top: SidepartRailgun = $OrbTop
@onready var orb_bot: SidepartRailgun = $OrbBot
@onready var components: Array[SidepartRailgun] = [laser_left, laser_right, orb_top, orb_bot]

func initialize_phase_one() -> void:
	pass


func _ready() -> void:
	initialize_phase_one()
	EventBus.boss_fight_started.emit(self)  ## healthbar is assigned thru this, tho kinda spaghetty
	assert(boss_box, "fix boss box passing")
	main_boss_health_comp.initialize_main_health_comp(boss_box)
	main_boss_health_comp.main_part_damaged.connect(take_boss_damage)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func take_boss_damage(damage: float):
	current_HP = max(current_HP - damage, 0)


func update_healthbar() -> void:
	if boss_HP_bar:
		boss_HP_bar.value = (current_HP/current_MAX_HP) * boss_HP_bar.max_value


func begin_phase_two() -> void:
	for c in components:
		"""
		if c is dead
		reconstruct c
		"""
		c.disable_reconstruct()
