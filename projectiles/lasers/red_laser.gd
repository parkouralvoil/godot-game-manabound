extends Area2D
class_name Laser

@onready var raycast: RayCast2D = $RayCast2D
@onready var line: Line2D = $Line2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var casting_particle: GPUParticles2D = $CastingParticle
@onready var impact_particle: GPUParticles2D = $ImpactParticle
var segment: SegmentShape2D
var blink: float = 0.5
var duration: float = 0.5

var width: float = 5
var element: CombatManager.Elements = CombatManager.Elements.NONE
var damage: float = 1

var is_casting: bool = false :
	set(value):
		is_casting = value
		update()
		if is_casting:
			resize_hitbox()
			appear()
		else:
			disappear()


func _ready() -> void:
	set_physics_process(false)
	set_deferred("monitoring", false)
	line.hide()
	segment = SegmentShape2D.new()
	#casting_particle.process_material = casting_particles_resource.duplicate()
	## ^ DO LOCAL TO SCENE INSTEAD
	collision_shape.shape = segment

func _physics_process(_delta: float) -> void:
	update()

func update() -> void:
	var cast_point: Vector2 = raycast.target_position
	raycast.force_raycast_update()
	resize_hitbox()
	#print(monitoring)
	if raycast.is_colliding():
		cast_point = to_local(raycast.get_collision_point())
		update_particles()
	line.points[1] = cast_point

func resize_hitbox() -> void:
	segment.b = line.points[1]
	#var rect: RectangleShape2D = collision_shape.shape
	#rect.size.x = width
	#var length: float = line.points[1].length()
	#rect.size.y = max(abs(length), width)
	#collision_shape.rotation = line.points[0].direction_to(line.points[1]).angle() + PI/2
	#collision_shape.position = (line.points[0] + line.points[1]) / 2
	#collision_shape.shape = rect

func emitting() -> void:
	# line is fully wide
	# raycast now hurts player
	pass


func appear() -> void:
	var initial: Color = Color(0.5, 0, 0, 0.6)
	var final: Color = Color(0.5, 0.2, 0.2, 0.4)
	var blink_start: Color = Color(0.5, 0.1, 0.1, 1)
	var blink_end: Color = Color(0.5, 0.1, 0.1, 0.2)
	show()
	line.show()
	line.width = 2
	line.modulate = initial
	await get_tree().create_timer(2).timeout
	line.width = 5
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(line, "modulate", blink_end, 0.5).from(blink_start)
	tween.tween_property(line, "modulate", blink_end, 0.5).from(blink_start)
	tween.tween_property(line, "modulate", Color(1.2, 0.2, 0.2, 0.7), 0.05).from(final)
	await tween.finished
	emit()


func emit() -> void:
	set_deferred("monitoring", true)
	set_physics_process(true)
	update_particles()
	casting_particle.emitting = true
	if raycast.is_colliding():
		impact_particle.emitting = true
	
	line.modulate = Color(2.5, 0.2, 0.2)
	line.width = width


func update_particles() -> void:
	@warning_ignore("unsafe_property_access") ## godot tripping bruh
	casting_particle.process_material.direction = Vector3(line.points[1].x,
			line.points[1].y,
			0)
	if monitoring:
		impact_particle.position = to_local(raycast.get_collision_point())
		impact_particle.global_rotation = raycast.get_collision_normal().angle() - PI/2


func _on_area_entered(hurtbox: Area2D) -> void:
	if hurtbox.has_method("hit"):
		hurtbox.hit(damage, element)


func disappear() -> void:
	# raycast disabled
	# line disappears
	# after await, finish
	var tween: Tween = create_tween()
	casting_particle.emitting = false
	impact_particle.emitting = false
	set_deferred("monitoring", false)
	tween.tween_property(line, "width", 0, 0.25).from(width)
	await tween.finished
	hide()
