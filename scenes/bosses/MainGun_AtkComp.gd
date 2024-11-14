extends Node2D

@onready var e: RailgunMainGun = owner

var aim_angle: float
var rotation_speed: float = 1.25

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var target_direction: Vector2 = EnemyAiManager.player_position - global_position
	var angle_to: float = self.transform.x.angle_to(target_direction)
	aim_angle = rotation
	e.sprite_main.rotation = rotation - PI/2
	self.rotate(sign(angle_to) * min(delta * rotation_speed, abs(angle_to)))
