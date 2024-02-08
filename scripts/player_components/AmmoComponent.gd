extends Node2D

@onready var AM: AbilityManager = get_parent()
@onready var t_ammo_regen: Timer = $ammo_regen

func _process(delta):
	if t_ammo_regen.is_stopped() and AM.ammo < AM.max_ammo and !PlayerInfo.basic_attacking:
		t_ammo_regen.start()

func _on_ammo_regen_timeout():
	AM.ammo += 1
