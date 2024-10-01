extends Area2D
class_name DamageImpact

# BulletImpact VS DamageImpact
	# bul impact: it only serves as decor (sprite 2d and timer)
	# dmg Impact: it deals dmg/procs elems (has area2d node)


@export var opaqueness: float = 1
@export var transparency_limit: float = 0.1
@export var decay_rate: float = 4

var damage: float = 0 ## 0 dmg means it only procs element, this is set by component
var ep: float = 0 ## determines strength of reaction/debuff
@export var element: CombatManager.Elements
var debuff: CombatManager.Debuffs = CombatManager.Debuffs.NONE

@onready var sprite: Sprite2D = $Sprite2D
@onready var t_lifespan: Timer = $hitbox_lifespan
@onready var scolor: Color = sprite.modulate ## starting color

func _ready() -> void:
	sprite.modulate = Color(scolor.r, scolor.g, scolor.b, opaqueness)
	self.connect("area_entered", _on_area_entered)
	t_lifespan.connect("timeout", _on_lifespan_timeout )
	t_lifespan.one_shot = true
	t_lifespan.autostart = true


func _physics_process(delta: float) -> void:
	sprite.modulate = Color(scolor.r, scolor.g, scolor.b, opaqueness)
	opaqueness = lerp(opaqueness, 0.0, decay_rate * delta)
	
	if opaqueness <= transparency_limit:
		queue_free()


func _on_lifespan_timeout() -> void: # instead of it being when it disappears, it just disables the hitbox
	monitoring = false


func _on_area_entered(hurtbox: Area2D) -> void:
	if hurtbox.has_method("hit"):
		hurtbox.hit(damage, element, ep)
	if hurtbox.has_method("apply_debuff"):
		hurtbox.apply_debuff(debuff, ep)
