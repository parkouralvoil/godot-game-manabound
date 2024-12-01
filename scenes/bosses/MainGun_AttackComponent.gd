extends Node2D

@export var bullet_origin: Marker2D
@export_category("Bullet Types")
@export var ShotgunBulletPath: PackedScene
@export var WidespreadBulletPath: PackedScene
@export var RailgunBulletPath: PackedScene

@export_category("Attack SFX")
@export var shotgun_sfx: AudioStream
@export var machinegun_sfx: AudioStream
@export var railgun_fire_sfx: AudioStream

enum ATK_MODE {
	BOW,
	GUN,
}
"""
0 - spreadshot > widespread
1 - spreadshot > widespread
2 - change mode, + 1
3 - machinegun fire > railgun
4 - change mode, back to 0
"""
var change_mode_flag: int = 0 ## switch to gun by 2

var max_ammo: int = 2
var ammo: int = max_ammo:
	set(val):
		ammo = val
		for i in range(max_ammo):
			if i < ammo:
				sprite_ammo[i].show()
			else:
				sprite_ammo[i].hide()

var aim_angle: float
var default_rotation_speed: float = 2
var rotation_speed: float = default_rotation_speed
var attacking: bool = false

var atk_flag: int = 1

var charging: bool = false
var interrupted: bool = false

@onready var t_firerate: Timer = $firerate
@onready var t_reload: Timer = $reload
@onready var e: RailgunMainGun = owner
@onready var sprite_ammo: Array[Sprite2D] = [$AmmoSpriteContainer/ammo1, $AmmoSpriteContainer/ammo2]
@onready var charge_particles: GPUParticles2D = $ChargingAttack
@onready var charging_player: AudioStreamPlayer2D = $ChargingSoundPlayer
@onready var rapid_player: AudioStreamPlayer2D =  $RapidSoundPlayer
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	e.attack_interrupted.connect(charged_attack_interrupt)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var target_direction: Vector2 = EnemyAiManager.player_position - global_position
	var angle_to: float = self.transform.x.angle_to(target_direction)
	aim_angle = rotation
	e.sprite_main.rotation = rotation - PI/2
	self.rotate(sign(angle_to) * min(delta * rotation_speed, abs(angle_to)))
	
	if not e.fight_started:
		return
	
	if ammo == max_ammo and not attacking:
		if e:
			phase1_behavior()
		else:
			pass ##phase 2 behavior


func phase1_behavior() -> void:
	attacking = true
	if change_mode_flag < 2:
		if atk_flag == 1:
			attack_spreadshot()
			#attack_spreadshot()
			atk_flag = 2
		else:
			attack_widespread()
			atk_flag = 1
			change_mode_flag += 1
	elif change_mode_flag == 2:
		change_mode()
		change_mode_flag += 1
	elif change_mode_flag == 3:
		if atk_flag == 1:
			attack_rapid()
			atk_flag = 2
		else:
			attack_charged()
			atk_flag = 1
			change_mode_flag += 1
	elif change_mode_flag == 4:
		change_mode()
		change_mode_flag = 0


func change_mode() -> void:
	t_firerate.start(0.5)
	await t_firerate.timeout
	e.switch_modes()
	attacking = false


func shoot(projectile: PackedScene, direction: Vector2, speed: float) -> void:
	var pro_instance: Bullet = projectile.instantiate()
	if pro_instance:
		pro_instance.global_position = bullet_origin.global_position
		
		pro_instance.speed = speed
		pro_instance.direction = direction
		pro_instance.rotation = direction.angle()
		pro_instance.damage = 1.0
		pro_instance.set_collision_mask_value(3, true) ## to look for player
		pro_instance.set_collision_layer_value(6, true) ## for parry
		pro_instance.max_distance = 5000
		get_tree().root.add_child(pro_instance)
	elif pro_instance == null:
		print(projectile)


func attack_spreadshot() -> void:
	t_firerate.start(0.5)
	await t_firerate.timeout
	
	var spread := 4
	var speed := 320
	for i in range(2):
		rotation_speed = default_rotation_speed/2
		for j in range(2):
			SoundPlayer.play_sound_2D(global_position, shotgun_sfx, -5, 1.1)
			for offset in range(-2, 3):
				var angle := aim_angle + deg_to_rad(spread * offset)
				shoot(ShotgunBulletPath, Vector2.RIGHT.rotated(angle), speed)
			t_firerate.start(0.15)
			await t_firerate.timeout
		rotation_speed = default_rotation_speed
		ammo -= 1
		t_firerate.start(0.3)
		await t_firerate.timeout
	attack_finished(ATK_MODE.BOW)

func attack_widespread() -> void:
	t_firerate.start(0.5)
	await t_firerate.timeout
	
	var spread := 22
	var speed := 160
	var slight_offset := 0
	
	for i in range(2):
		SoundPlayer.play_sound_2D(global_position, shotgun_sfx, -3, 0.85)
		for offset in range(-4, 5):
			var angle := aim_angle + deg_to_rad(spread * offset + slight_offset)
			shoot(WidespreadBulletPath, Vector2.RIGHT.rotated(angle), speed)
		ammo -= 1
		slight_offset = 10
		t_firerate.start(0.65)
		await t_firerate.timeout
	attack_finished(ATK_MODE.BOW)

func attack_finished(mode: ATK_MODE) -> void:
	attacking = false
	t_reload.start()
	if mode == ATK_MODE.BOW:
		e.phase1_attack_done.emit()


func attack_rapid() -> void:
	t_firerate.start(0.5)
	await t_firerate.timeout
	
	var speed := 360
	for i in range(2): ## 16 shots total
		rotation_speed = default_rotation_speed/2
		for j in range(8):
			rapid_player.play()
			shoot(ShotgunBulletPath, Vector2.RIGHT.rotated(aim_angle), speed)
			t_firerate.start(0.2)
			await t_firerate.timeout
		ammo -= 1
	rotation_speed = default_rotation_speed
	rapid_player.stop()
	attack_finished(ATK_MODE.GUN)

func attack_charged() -> void:
	t_firerate.start(0.5)
	await t_firerate.timeout
	
	var speed := 700
	for i in range(2): ## 2 charged shots
		charging = true
		interrupted = false
		charge_particles.emitting = true
		t_firerate.start(4)
		if not charging_player.playing:
			charging_player.play()
		await t_firerate.timeout
		
		charging_player.stop()
		if not interrupted:
			SoundPlayer.play_sound_2D(global_position, railgun_fire_sfx, -4, 1.1)
			shoot(RailgunBulletPath, Vector2.RIGHT.rotated(aim_angle), speed)
		charge_particles.emitting = false
		charging = false
		ammo -= 1
		t_firerate.start(2)
		await t_firerate.timeout
	
	attack_finished(ATK_MODE.GUN)


func charged_attack_interrupt() -> void:
	if charging:
		charging_player.stop()
		e.spawn_dmg_number("INTERRUPTED!", Color(0.9, 0.9, 0.9)) ## bruh
		charging = false
		interrupted = true
		charge_particles.emitting = false


func _on_reload_timeout() -> void:
	ammo = min(ammo + 1, 2)
	if ammo < 2:
		t_reload.start()
	
