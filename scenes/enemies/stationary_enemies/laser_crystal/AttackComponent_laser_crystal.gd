extends Node2D
class_name AttackComponent_LaserCrystal

@onready var t_reload: Timer = $reload
@onready var t_duration: Timer = $laser_duration
@onready var laser: Array[Laser] = [$red_laser, $red_laser2]

@onready var e: BaseEnemy = owner

var max_range: float = 1000

var max_ammo: int = 1
var ammo: int = 0

func _ready() -> void:
	t_reload.start()


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
	
