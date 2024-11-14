extends BaseEnemy
class_name RailgunMainGun

var invulnerable: bool = false
var hit_tween: Tween

@onready var sprite_base: Sprite2D = $base

func _physics_process(_delta: float) -> void:
	# handles vision
	pass


func take_damage(damage: float, element: CombatManager.Elements, ep: float = 0) -> void:
	if health_component and not invulnerable:
		health_component.raw_damage_received(damage, element, ep)
		if hit_tween:
			hit_tween.kill()
		hit_tween = create_tween()
		hit_tween.tween_property(sprite_main, "material:shader_parameter/flashState", 0, 0.2).from(0.3)
		hit_tween.parallel().tween_property(sprite_base, "material:shader_parameter/flashState", 0, 0.2).from(0.3)
