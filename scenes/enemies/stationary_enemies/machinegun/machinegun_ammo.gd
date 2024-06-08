extends Node2D

@export var entity: CharacterBody2D
@onready var sprite_ammo: Sprite2D = $Sprite2D_ammo1

var current_ammo: int

func _ready() -> void:
	current_ammo = entity.ammo

func _process(_delta: float) -> void:
	if current_ammo != entity.ammo:
		current_ammo = entity.ammo
		match current_ammo:
			1:
				sprite_ammo.show()
			0:
				sprite_ammo.hide()
