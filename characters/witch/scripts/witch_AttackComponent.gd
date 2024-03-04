extends Node2D

@export var IceSpikeScene: PackedScene

@onready var character: Character = owner

@onready var t_firerate: Timer = $firerate
@onready var t_recoil: Timer = $recoil

#for bullets
var bullet_speed: float = 300
var damage: float = 5
var max_distance: float = 250
var element: CombatManager.Elements = CombatManager.Elements.ICE

var can_shoot: bool = true

func _process(_delta: float) -> void:
	can_shoot = PlayerInfo.current_state != PlayerInfo.States.STANCE
	
	if !character.enabled:
		return
	
	if !t_recoil.is_stopped(): 
		character.sprite_look_at(PlayerInfo.aim_direction)
		PlayerInfo.basic_attacking = true
	elif t_recoil.is_stopped() or !can_shoot:
		PlayerInfo.basic_attacking = false
	
	if Input.is_action_pressed("left_click") and character.ammo > 0 and can_shoot:
		if t_firerate.is_stopped():
			burst_shoot()
			t_firerate.start()
			t_recoil.start()
			character.set_player_velocity(Vector2.ZERO)

func shoot(bullet: PackedScene) -> void:
	assert(bullet, "bruh its missing")
	var bul_instance: Bullet = bullet.instantiate()
	var direction: Vector2 = PlayerInfo.aim_direction
	character.apply_player_cam_shake(1)
	character.ammo -= 1
	
	bul_instance.global_position = self.global_position
	
	bul_instance.speed = bullet_speed
	bul_instance.damage = damage
	bul_instance.max_distance = max_distance
	bul_instance.direction = direction
	bul_instance.element = element
	bul_instance.rotation = direction.angle()
	bul_instance.set_collision_mask_value(4, true)
	get_tree().root.add_child(bul_instance)

func burst_shoot() -> void:
	shoot(IceSpikeScene)
