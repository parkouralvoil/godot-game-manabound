extends Node2D

@export var FrostNovaScene: PackedScene

# this should have 2 charges
# by default, it only has 1 charge, strong single target bullet (like ac6 linear rifle), no piercing
# with upgrades:
# 2nd charge: piercing bullet, disappears on wall collision
# we can just have the explosion impact be "shockwave dealing minor dmg and additional lightning elem proc"

@onready var character: Character = owner

var bullet_speed: float = 600

func _process(delta: float) -> void:
	raise_charge(delta)
	
	if !character.enabled:
		return
	
	PlayerInfo.current_charge_type = PlayerInfo.ChargeTypes.PASSIVE
	
	if character.charge >= character.max_charge:
		if PlayerInfo.current_state == PlayerInfo.States.STANCE:
			character.sprite_look_at(PlayerInfo.mouse_direction)
		elif Input.is_action_just_released("right_click"):
			spend_charge()

func spawn_area_effect(area_effect: PackedScene, target_pos: Vector2) -> void:
	assert(area_effect, "missing proj")
	
	var effect_instance := area_effect.instantiate()
	effect_instance.global_position = target_pos
	
	get_tree().root.add_child(effect_instance)

func raise_charge(delta: float) -> void:
	character.charge = min(character.max_charge, character.charge + character.charge_rate * delta)

func spend_charge() -> void:
	spawn_area_effect(FrostNovaScene, get_global_mouse_position())
	character.charge = 0
