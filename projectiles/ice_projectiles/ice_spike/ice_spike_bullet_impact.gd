extends DamageImpact

@onready var sprite_start: Sprite2D = $Sprite2D/Sprite2D_start_explosion
@onready var sprite_2nd_icicle: Sprite2D = $Sprite2D_second_icicle

var start_explosion_done: bool = false
var first_icicle: bool = false

var second_icicle_dmg: float = 999


func _ready() -> void:
	self.connect("area_entered", _on_area_entered)
	t_lifespan.connect("timeout", _on_lifespan_timeout )
	t_lifespan.one_shot = true
	t_lifespan.autostart = true
	explosion_animation()


func _physics_process(delta: float) -> void:
	if start_explosion_done:
		sprite.modulate = Color(1,1,1, opaqueness)
		sprite_2nd_icicle.modulate = Color(1,1,1, opaqueness)
		opaqueness = lerp(opaqueness, 0.0, decay_rate * delta)
	
	if opaqueness <= transparency_limit:
		queue_free()


func explosion_animation() -> void:
	sprite.self_modulate = Color(1,1,1,0)
	sprite_start.show()
	var tween: Tween = create_tween()
	tween.tween_property(sprite_start, "modulate", Color(1,1,1, 0.2), 0.1).from(Color(1,1,1,1))
	await tween.finished
	start_explosion_done = true
	sprite.self_modulate = Color(1,1,1,1)
	if first_icicle:
		await get_tree().create_timer(0.05).timeout
		sprite_2nd_icicle.show()


func _on_area_entered(hurtbox: Area2D) -> void:
	if hurtbox.has_method("hit"):
		hurtbox.hit(damage, element)
		if first_icicle:
			hurtbox.hit(second_icicle_dmg, element)
	
	if hurtbox.has_method("apply_debuff"):
		hurtbox.apply_debuff(debuff)
		if first_icicle:
			hurtbox.apply_debuff(debuff)
