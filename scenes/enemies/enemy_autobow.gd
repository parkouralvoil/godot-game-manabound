extends CharacterBody2D

# general note:
# rn the entity stores the Vision and Health component, cuz they seem fairly simple rn
# BUT ideally i turn these into components, and connect them to eachother with export

var bulletSFX_scene := load("res://scenes/projectiles/bullet_impact.tscn") # i shuold rename this
var enemy_dead_texture: AtlasTexture = load("res://resources/enemy_dead.tres")

@onready var sprite_main: Sprite2D = $Sprite2D_main
@onready var ammo_container: Node2D = $ammo_container

var max_health: float = 20.0
var health: float = max_health

var target_pos: Vector2 = Vector2.ZERO
var vision_range: float = 500.0

var can_fire: bool = false
var aim_direction: Vector2 = Vector2.ZERO

#attack component and ammo container:
var max_ammo: int = 3
var ammo: int = max_ammo

func _physics_process(delta):
	# handles vision
	target_pos = EnemyAiManager.player_position
	can_fire = (target_pos - global_position).length() < vision_range
	
	aim_direction = Vector2.ZERO.direction_to(target_pos - self.global_position).normalized()

func take_damage(damage: float):
	if health - damage > 0:
		health -= damage
	else:
		make_impact()
		queue_free()

func make_impact():
	var impact: Sprite2D = bulletSFX_scene.instantiate()
	impact.global_position = global_position
	impact.texture = enemy_dead_texture
	impact.decay_rate = 10
	impact.scale = Vector2(2, 2)
	get_tree().root.add_child(impact)
