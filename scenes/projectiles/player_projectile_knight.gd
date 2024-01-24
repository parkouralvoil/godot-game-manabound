extends CharacterBody2D

# my plan to code projectiles:
# 1. the node who shot it should set the speed, dmg, lifespan, direction of projectile 
# 	- done inside the node's "spawn projectile" code
# 2. main script should delete itself on contact with tiles

var speed: float = 50.0
var damage: float = 2.0
var lifespan: float = 1.0
var direction: Vector2 = Vector2.ZERO

@onready var t_lifespan: Timer = $Timer_lifespan

func _ready():
	t_lifespan.wait_time = lifespan
	t_lifespan.start()
	velocity = speed * direction

func _process(delta):
	if move_and_slide():
		queue_free()

func _on_timer_lifespan_timeout():
	queue_free()
