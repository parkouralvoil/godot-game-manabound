extends Node2D

@onready var e: Enemy_MachineGun = owner
@onready var sprite_ammo: Sprite2D = $Sprite2D_ammo1

var current_ammo: int

func _ready() -> void:
	current_ammo = e.ammo

func _process(_delta: float) -> void:
	if current_ammo != e.ammo:
		current_ammo = e.ammo
		match current_ammo:
			1:
				sprite_ammo.show()
			0:
				sprite_ammo.hide()
