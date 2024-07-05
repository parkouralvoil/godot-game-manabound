extends Area2D
class_name DamageImpact

# BulletImpact VS DamageImpact
	# bul impact: it only serves as decor (sprite 2d and timer)
	# dmg Impact: it deals dmg/procs elems (has area2d node)

# OK SO, I'm essentially using this LIKE a resource, but I set it as a PackedScene
# why? Cuz i wanna see the changes i make to the thing, so i need the nodes editable rather than
# having a resource for sprite2d and collision and etc etc itll get ugly

@export var opaqueness: float = 1
@export var transparency_limit: float = 0.1
@export var decay_rate: float = 4

@export var damage: float = 0 # no dmg, it should only proc the element
@export var element: CombatManager.Elements
var debuff: CombatManager.Debuffs = CombatManager.Debuffs.NONE

@onready var sprite: Sprite2D = $Sprite2D
@onready var t_lifespan: Timer = $hitbox_lifespan
@onready var scolor: Color = sprite.modulate ## starting color

func _ready() -> void:
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
		hurtbox.hit(damage, element)
	if hurtbox.has_method("apply_debuff"):
		hurtbox.apply_debuff(debuff)
		
