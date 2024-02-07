extends Node2D

@export var p: Player
@onready var t_ammo_regen: Timer = $ammo_regen
@onready var t_ult_regen: Timer = $ult_regen
var max_ammo: int = 9
var ammo: int = max_ammo

var max_ult_counts: int = 1
var ult_counts: int = max_ult_counts

func _process(delta):
	if t_ammo_regen.is_stopped() and ammo < max_ammo and !p.is_firing:
		t_ammo_regen.start()
	if t_ult_regen.is_stopped() and ult_counts < max_ult_counts:
		t_ult_regen.start()

func _on_ammo_regen_timeout():
	ammo += 1

func _on_ult_regen_timeout():
	ult_counts += 1
