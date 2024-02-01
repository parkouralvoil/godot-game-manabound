extends CharacterBody2D

var explosionSFX_scene := load("res://scenes/projectiles/bullet_impact.tscn") # i shuold rename this
var enemy_dead_texture: AtlasTexture = load("res://resources/enemy_dead.tres")

@onready var sprite_main: Sprite2D = $Sprite2D_main

var max_health: float = 50.0
var health: float = max_health


func take_damage(damage: float):
	if health - damage > 0:
		health -= damage
	else:
		make_impact()
		queue_free()

func make_impact():
	var impact: Sprite2D = explosionSFX_scene.instantiate()
	impact.global_position = global_position
	impact.texture = enemy_dead_texture
	impact.decay_rate = 10
	impact.scale = Vector2(3, 3)
	get_tree().root.add_child(impact)
