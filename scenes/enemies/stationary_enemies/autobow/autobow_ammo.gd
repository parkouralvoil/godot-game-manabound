extends Node2D

@onready var atk_comp: AttackComponent_Autobow = get_parent()
@onready var sprite_ammo: Array[Sprite2D] = [$Sprite2D_ammo1, $Sprite2D_ammo2, $Sprite2D_ammo3]

var current_ammo: int

func _ready() -> void:
	current_ammo = atk_comp.ammo

func _process(_delta: float) -> void: ## should just use signals...
	if current_ammo != atk_comp.ammo:
		current_ammo = atk_comp.ammo
		match current_ammo:
			3:
				sprite_ammo[0].show()
				sprite_ammo[1].show()
				sprite_ammo[2].show()
			2:
				sprite_ammo[0].hide()
			1:
				sprite_ammo[0].hide()
				sprite_ammo[1].hide()
			0:
				sprite_ammo[0].hide()
				sprite_ammo[1].hide()
				sprite_ammo[2].hide()
