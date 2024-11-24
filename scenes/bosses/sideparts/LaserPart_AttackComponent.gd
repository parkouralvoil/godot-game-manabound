extends Node2D
class_name LaserPart_AttackComponent

var max_range := 1000

var max_ammo: int = 1
var ammo: int = 0
var target: Vector2 = Vector2.DOWN

@onready var e: SidepartRailgun = owner
@onready var t_reload: Timer = $reload
@onready var t_duration: Timer = $laser_duration
@onready var laser: Laser = $red_laser


## to show how to spin:
#func _physics_process(delta: float) -> void:
	#var rot_speed: float = PI/30 * delta
	#sprite_main.rotate(rot_speed)
	#target[0] = target[0].rotated(rot_speed)
	#target[1] = target[1].rotated(rot_speed)
	#for i in range(2):
		#attack_comp.laser[i].raycast.target_position = target[i] * attack_comp.max_range
		#attack_comp.laser[i].update()


func _physics_process(_delta: float) -> void:
	if not e.fight_started:
		pass
	elif e.invulnerable or not e.visible: ## stop attacking, im dead / under construction
		t_duration.stop()
		t_reload.stop()
		halt_attack()
	elif ammo == max_ammo and t_duration.is_stopped():
		var offset_angle := RNG.random_float(-0.2, 0.2)
		var target_dir := (EnemyAiManager.player_position - global_position).normalized()
		laser.raycast.target_position = target_dir.rotated(offset_angle) * max_range
		laser.update()
		laser.is_casting = true
		#print_debug("fired laser")
		t_duration.start()
	elif ammo == 0 and t_reload.is_stopped():
		t_reload.start()


func _on_reload_timeout() -> void:
	ammo = max_ammo


func _on_laser_duration_timeout() -> void:
	laser.is_casting = false
	t_reload.start()
	ammo = 0


func halt_attack() -> void: ## if orb part dies
	laser.is_casting = false
	t_duration.stop()
	ammo = 0
