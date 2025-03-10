extends Node2D
class_name Character_AmmoComponent

@onready var character: Character = owner
@onready var PlayerInfo: PlayerInfoResource ## given by AM

@onready var t_ammo_regen: Timer = $ammo_regen

func _ready() -> void:
	assert(t_ammo_regen, "Missing node, double check timer's name for ammo comp")
	assert(character, "MissingNode, where is character")
	t_ammo_regen.connect("timeout", _on_ammo_regen_timeout)


func _process(_delta: float) -> void:
	if t_ammo_regen.is_stopped() and (character.stats.ammo < character.stats.max_ammo 
		and (not PlayerInfo.recoiling_from_basic_atk or not character.enabled)):
		t_ammo_regen.wait_time = character.stats.reload_time
		t_ammo_regen.start()
	
	if (character.stats.ammo >= character.stats.max_ammo or 
			(PlayerInfo.recoiling_from_basic_atk and character.enabled) or
			character.is_dead
	):
		t_ammo_regen.stop()


func _on_ammo_regen_timeout() -> void:
	character.stats.ammo += 1
