extends EnemyHealthComponent
class_name NormalEnemyHealth

var color_tier1 := Color(1, 0.21, 0.32)
var color_tier2 := Color(1, 0.4, 0.015)
var color_tier3 := Color(0.87, 0, 1)

@onready var healthbar: ProgressBar = $Healthbar
@onready var HBox: HBoxContainer = $Box


func set_healthbar_properties(og_length: float) -> void: ## called by BaseEnemy.gd
	var size: float = clampf(og_length/4.5, 5, 100)
	
	healthbar.size.x = size
	healthbar.position.x = -size/2
	HBox.position.x = -size/2
	
	if og_length >= e.max_health: ## x1 HP
		healthbar.modulate = color_tier1
	elif og_length * 3 >= e.max_health: ## x3 HP
		healthbar.modulate = color_tier2
	else: ## more than x2 HP
		healthbar.modulate = color_tier3
