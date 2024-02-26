extends Node2D
class_name EnemyDebuffComponent

@onready var e: BaseEnemy = owner

@onready var particles: GPUParticles2D = $GPUParticles2D_supercond
@onready var t_superconduct: Timer = $superconduct

var color_sc: Color = Color(0.8, 0.5, 1)

# elemental reactions

# path: health component -> enemy script -> debuff component
# why this is the path:
# health comp		checks what reaction should occur
# enemy script		might want to change the effect of the reaction, also lets me pass it to all BaseEnemy comps
# debuff comp		applies reaction

	# TODO: consult better progamer if theres a better way to do it

func receive_superconduct() -> void:
	var tween: Tween = create_tween()
	particles.restart()
	e.reload_time = e.default_reload_time * 2
	
	tween.tween_property(e.sprite_main, "modulate", Color(1, 1, 1), 7).from(color_sc)
	
	t_superconduct.start()

func _on_superconduct_timeout() -> void:
	e.reload_time = e.default_reload_time
	e.sprite_main.modulate = Color(1, 1, 1)
