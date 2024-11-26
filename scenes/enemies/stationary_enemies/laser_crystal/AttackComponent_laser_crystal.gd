extends Node2D
class_name AttackComponent_LaserCrystal


var max_range: float = 1000

var max_ammo: int = 1
var ammo: int = 0
var target: Array[Vector2] = [Vector2.DOWN, Vector2.UP]

@onready var e: BaseEnemy = owner
@onready var t_reload: Timer = $reload
@onready var t_duration: Timer = $laser_duration
@onready var laser: Array[Laser] = [$red_laser, $red_laser2]


func _ready() -> void:
	t_reload.start()
	e.attack_interrupted.connect(interrupt_attack)
	##e.NOTIFICATION_READY
	if RNG.roll_probability(0.5) and e.sprite_main:
		e.sprite_main.rotation = PI/2
		target[0] = Vector2.LEFT
		target[1] = Vector2.RIGHT
	elif not e.sprite_main:
		pass #print_debug(e.get_node("Sprite2D_main"))
	for i in range(2):
		laser[i].raycast.target_position = target[i] * max_range
		laser[i].update()


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
	if ammo == max_ammo and t_duration.is_stopped():
		for las in laser:
			las.is_casting = true
		t_duration.start()


func _on_reload_timeout() -> void:
	ammo = max_ammo
	e.sprite_main.self_modulate = Color(1, 1, 1)


func _on_laser_duration_timeout() -> void:
	for las in laser:
		las.is_casting = false
	t_reload.start()
	ammo = 0
	e.sprite_main.self_modulate = Color(0.6, 0.6, 0.6)


func interrupt_attack() -> void:
	if laser[0].is_casting:
		for l in laser:
			l.is_casting = false
		e.spawn_dmg_number("INTERRUPTED!", Color(1, 0.9, 0.9))
		t_duration.stop()
		_on_laser_duration_timeout()
