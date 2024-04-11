extends Node2D

@export var entity: CharacterBody2D
@onready var sprite_ammo: Array[Sprite2D] = [$Sprite2D_ammo1, $Sprite2D_ammo2, $Sprite2D_ammo3]

var current_ammo: int

func _ready() -> void:
	current_ammo = entity.ammo

func _process(_delta: float) -> void:
	if current_ammo != entity.ammo:
		current_ammo = entity.ammo
		match current_ammo:
			1:
				sprite_ammo[0].show()
				sprite_ammo[1].show()
				sprite_ammo[2].show()
			0:
				sprite_ammo[0].hide()
				sprite_ammo[1].hide()
				sprite_ammo[2].hide()
