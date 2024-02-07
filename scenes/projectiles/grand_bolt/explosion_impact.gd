extends Area2D

var transparency: float = 1
var decay_rate: float = 4

var damage: float = 5

@onready var sprite: Sprite2D = $Sprite2D

func _physics_process(delta):
	sprite.modulate = Color(1,1,1, transparency)
	transparency = lerp(transparency, 0.0, decay_rate * delta)
	
	if transparency <= 0.03:
		queue_free()

func _on_lifespan_timeout(): # instead of it being when it disappears, it just disables the hitbox
	monitoring = false

func _on_area_entered(hurtbox: Area2D):
	if hurtbox.has_method("hurtbox_hit"):
		hurtbox.hurtbox_hit(damage)
