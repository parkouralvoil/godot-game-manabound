extends Node2D
class_name OrbPart_AttackComponent

var can_fire: bool
var vision_range: float = 1000
var max_ammo: int = 1
var ammo: int = 0

var line_og_color: Color = Color(0.9, 0.9, 1, 0.7)

@onready var t_reload: Timer = $reload
@onready var spawner: OrbExplosionSpawn = $orb_explosion_spawn
@onready var line: Line2D = $Line2D
@onready var e: SidepartRailgun = owner

func _ready() -> void:
	e.reload_time_changed.connect(update_reload)
	line.points[0] = position
	line.hide()


func _physics_process(_delta: float) -> void:
	if not e.fight_started:
		return
	if e.invulnerable or not e.visible: ## stop attacking, im dead / under construction
		can_fire = false
		ammo = 0
		if not spawner.attack_done:
			spawner.interrupt_impact()
		return
	
	if not spawner.attack_done:
		can_fire = false
	else:
		line.hide()
		can_fire = (EnemyAiManager.player_position - global_position).length() < vision_range
		if t_reload.is_stopped() and ammo <= 0:
			t_reload.start()
			e.sprite_main.modulate = Color(0.6, 0.6, 0.6)
	
	if can_fire and ammo > 0:
		e.sprite_main.modulate = Color(1, 1, 1)
		attack()


func attack() -> void:
	var rand_x: float = RNG.random_float(-100, 100)
	var rand_y: float = RNG.random_float(-100, 100)
	var target_pos: Vector2 = Vector2(EnemyAiManager.player_position.x + rand_x,
			min(EnemyAiManager.player_position.y + rand_y, -20)) # dont let it fire beyond camera border
	spawner.prepare_impact(target_pos)
	line.show()
	var tween: Tween = create_tween()
	tween.tween_property(line, "default_color", Color(0.5, 0.5, 0.6, 0), 0.8).from(line_og_color)
	line.points[1] = to_local(target_pos)
	ammo = 0


func _on_reload_timeout() -> void:
	ammo = max_ammo
	e.sprite_main.modulate = Color(1, 1, 1)


func update_reload(new_reload: float) -> void:
	t_reload.wait_time = new_reload
