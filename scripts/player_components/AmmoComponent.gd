extends Node2D

@export var p: Player
@onready var t_ammo_regen: Timer = $ammo_regen
var max_ammo: int = 9
var ammo: int = max_ammo

func _process(delta):
	if t_ammo_regen.is_stopped() and ammo < max_ammo and !p.is_firing:
		t_ammo_regen.start()

func _on_ammo_regen_timeout():
	ammo += 1
