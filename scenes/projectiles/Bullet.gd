extends Area2D
class_name Bullet

@export var bullet_impact: PackedScene 
# i could make bullet impact into a resource
# and then make additional effects as another resource

var max_distance: float = 300.0
var speed: float = 300.0

var _travelled_distance: float = 0.0
var direction: Vector2 = Vector2.ZERO

# im not making these export, it should be up to the Attack/Ult comp to change these
var damage: float = 5
var element: CombatManager.Elements = CombatManager.Elements.LIGHTNING

var impact_created: bool = false

func _ready() -> void:
	assert(bullet_impact, "missing bullet impact")

func _physics_process(delta: float) -> void:
	var distance: float = speed * delta
	var motion: Vector2 = transform.x * speed * delta
	
	position += motion
	
	_travelled_distance += distance
	if _travelled_distance > max_distance:
		disappear()

func _on_area_entered(hurtbox: Area2D) -> void:
	if hurtbox.has_method("hurtbox_hit"):
		hurtbox.hurtbox_hit(damage, element)
	disappear()

func _on_body_entered(_body: TileMap) -> void: # tilemap since thats the collision of the world
	disappear()

func make_impact() -> void:
	if !impact_created:
		impact_created = true
		var instance: Sprite2D = bullet_impact.instantiate()
		instance.global_position = global_position
		get_tree().root.call_deferred("add_child", instance)

func disappear() -> void:
	make_impact()
	queue_free()
