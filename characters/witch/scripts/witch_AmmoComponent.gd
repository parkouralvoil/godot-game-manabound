extends Node2D

@onready var character: Character = owner
@onready var t_ammo_regen: Timer = $ammo_regen

func _ready() -> void:
	t_ammo_regen.connect("timeout", _on_ammo_regen_timeout)

func _process(_delta: float) -> void:
	if t_ammo_regen.is_stopped() and (character.ammo < character.max_ammo and 
		(!PlayerInfo.basic_attacking or !character.enabled) ):
		t_ammo_regen.start()
	
	if character.ammo >= character.max_ammo or (PlayerInfo.basic_attacking and character.enabled):
		t_ammo_regen.stop()

func _on_ammo_regen_timeout() -> void:
	character.ammo += 1
