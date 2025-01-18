extends Control
class_name BossInfo

var boss_present: bool = false

@onready var boss_HP_bar: ProgressBar = %BossHP
@onready var boss_box: Container = %BossBox

func _ready() -> void:
	EventBus.level_loaded.connect(_update_cycle_room)
	EventBus.returned_to_mainhub.connect(_on_return_to_main_hub)
	EventBus.boss_fight_started.connect(_on_boss_fight_started)
	EventBus.boss_fight_ended.connect(_on_boss_fight_ended)
	hide()

func _on_boss_fight_started(boss_node: RailgunBoss) -> void:
	boss_node.boss_HP_bar = boss_HP_bar
	boss_node.boss_box = boss_box
	
	await get_tree().physics_frame ## this is HACK
	show()

func _on_boss_fight_ended() -> void:
	hide()

func _update_cycle_room() -> void:
	hide()

func _on_return_to_main_hub() -> void:
	hide()
