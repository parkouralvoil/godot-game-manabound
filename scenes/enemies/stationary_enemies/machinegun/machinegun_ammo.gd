extends Node2D

@onready var atk_comp: EnemyAttackComponent_Machinegun = get_parent()
@onready var sprite_ammo: Sprite2D = $ammo1

var current_ammo: int

func _ready() -> void:
	current_ammo = atk_comp.ammo

func _process(_delta: float) -> void:
	if current_ammo != atk_comp.ammo:
		current_ammo = atk_comp.ammo
		match current_ammo:
			1:
				sprite_ammo.show()
			0:
				sprite_ammo.hide()
