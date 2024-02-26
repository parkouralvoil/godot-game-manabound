extends Node2D

@onready var AM: AbilityManager = get_parent()
@onready var t_ammo_regen: Timer = $ammo_regen

func _ready() -> void:
	t_ammo_regen.connect("timeout", _on_ammo_regen_timeout)

func _process(_delta: float) -> void:
	if t_ammo_regen.is_stopped() and AM.ammo < AM.max_ammo and (!PlayerInfo.basic_attacking or !AM.enabled):
		t_ammo_regen.start()
	
	if AM.ammo >= AM.max_ammo or (PlayerInfo.basic_attacking and AM.enabled):
		t_ammo_regen.stop()

func _on_ammo_regen_timeout() -> void:
	AM.ammo += 1
