extends BaseEnemy
class_name RailgunMainGun
## mana orbs dropped are handled by railgun boss script (boss1)
signal phase1_attack_done()

var invulnerable: bool = true
var fight_started: bool = false ## after intro "cutscene"
var hit_tween: Tween
var current_mode: int = 0

var boss_defeated_flag: bool = false

@onready var sprite_base: Sprite2D = $base
@onready var sprite_bow: Sprite2D = $Sprite2D_main/bow
@onready var sprite_gun: Sprite2D = $Sprite2D_main/gun
@onready var change_mode_particles: GPUParticles2D = $ChangeModeParticles
@onready var atk_comp: Node2D = $AttackComponent

func _physics_process(_delta: float) -> void:
	# handles vision
	if boss_defeated_flag: ## shake
		var shake := RNG.random_float(-1.5, 1.5)
		position = Vector2(1, 0) + Vector2(shake, shake)


func take_damage(damage: float, element: CombatManager.Elements, ep: float = 0) -> void:
	if health_component and not invulnerable:
		health_component.raw_damage_received(damage, element, ep)
		show_hit_flash()

func show_hit_flash() -> void:
	if hit_tween:
		hit_tween.kill()
	hit_tween = create_tween()
	hit_tween.tween_property(sprite_main, "material:shader_parameter/flashState", 0, 0.2).from(0.3)
	hit_tween.parallel().tween_property(sprite_base, "material:shader_parameter/flashState", 0, 0.2).from(0.3)

func boss_defeated() -> void:
	atk_comp.queue_free()
	boss_defeated_flag = true

func switch_modes() -> void:
	change_mode_particles.restart()
	var t := create_tween()
	t.tween_property(sprite_main, "material:shader_parameter/flashState", 0, 0.3).from(0.5)
	if current_mode == 0: ## bow
		sprite_bow.hide()
		sprite_gun.show()
		current_mode = 1
	else: ## gun
		sprite_bow.show()
		sprite_gun.hide()
		current_mode = 0
