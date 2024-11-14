extends BaseEnemy
class_name SidepartRailgun

@onready var boss: RailgunBoss = owner

@onready var sprite_construction: Sprite2D = $Sprite2D_construction
@onready var hurtbox: HurtboxComponent = $BossHurtbox
@onready var collisionbox: CollisionShape2D = $CollisionShape2D
@onready var t_revive_check: Timer = $ReviveCheck
@onready var player_check: Area2D = $PlayerCheck

var can_reconstruct: bool = true ## set by main RailgunBoss
var player_blocking_construction: bool = false ## if player is at construction area
var invulnerable: bool = false

var hit_tween: Tween

func _ready() -> void:
	super()
	sprite_construction.modulate = Color(1, 1, 1, 0.7)
	t_revive_check.timeout.connect(_on_revive_check_timeout)

func take_damage(damage: float, element: CombatManager.Elements, ep: float = 0) -> void:
	if health_component and not invulnerable:
		health_component.raw_damage_received(damage, element, ep)
		if hit_tween:
			hit_tween.kill()
		hit_tween = create_tween()
		hit_tween.tween_property(sprite_main, "material:shader_parameter/flashState", 0, 0.2).from(0.4)


func disable_reconstruct() -> void:
	can_reconstruct = false


func sidepart_destroyed() -> void:
	hide()
	sprite_main.hide()
	hurtbox.monitorable = false
	collisionbox.set_deferred("disabled", true)
	## wait 4 seconds
	await get_tree().create_timer(8).timeout
	#print_debug("sidepart destroyed")
	t_revive_check.start()


func begin_reconstruction() -> void:
	invulnerable = true
	show()
	hurtbox.monitorable = true
	
	## forcefield
	for i in range(4): 
		var t1: Tween = create_tween()
		t1.tween_property(sprite_construction, "material:shader_parameter/color", Color(0.4, 0.4, 1), 0.5)
		t1.tween_property(sprite_construction, "material:shader_parameter/color", Color(0.8, 0.8, 1), 0.5)
		await t1.finished
	
	## flash white
	sprite_main.material.set_shader_parameter("flashState", 0.8)
	sprite_main.show()
	var t: Tween = create_tween()
	t.tween_property(sprite_main, "material:shader_parameter/flashState", 0, 1).from_current()
	await t.finished
	
	if health_component is SidepartRailgun_Health:
		health_component.reconstruction_finished()
	invulnerable = false


func _on_revive_check_timeout() -> void:
	if player_check.has_overlapping_bodies():
		return
	else:
		t_revive_check.stop()
		collisionbox.set_deferred("disabled", false)
		begin_reconstruction()
