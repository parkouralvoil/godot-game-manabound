extends Node2D
class_name Main # handles loading levels, saving player, etc.

const level_warehouse: PackedScene = preload("res://scenes/levels/blue_city/city_warehouse.tscn")
var enemy_chance: float = 0 :
	set(value):
		enemy_chance = clampf(value, 0, 1)
var enemy_chance_scaling: float = 0.5

@onready var playerholder: Node2D = $PlayerHolder
@onready var level: LevelManager = $city_warehouse
@onready var camera: Camera2D = $PlayerCamera
@onready var black_screen: ColorRect = $PlayerCamera/CanvasLayer/ColorRect 


func _ready() -> void:
	#remove_child(playerholder)
	EventBus.go_next_lvl.connect(load_next_lvl)
	enter_next_lvl()


func enter_next_lvl() -> void:
	if not has_node("PlayerHolder"):
		add_child(playerholder)
	var player: Player = playerholder.get_child(0)
	black_screen.show()
	camera.position_smoothing_enabled = false
	
	player.global_position = level.starting_pos
	camera.global_position = level.starting_pos
	level.enemy_holder.enemy_chance = enemy_chance
	print("EnemyChance: " + str(enemy_chance))
	level.enemy_holder.spawn_enemies()
	
	var t: Tween = create_tween()
	t.set_ease(Tween.EASE_OUT)
	t.tween_property(black_screen, "color", Color(0,0,0,0), 0.7)
	await t.finished
	camera.target_node = player
	camera.position_smoothing_enabled = true
	black_screen.hide()


func load_next_lvl(current_lvl: LevelManager) -> void:
	var inst: LevelManager
	var t: Tween = create_tween()
	enemy_chance += enemy_chance_scaling
	black_screen.show()
	t.set_ease(Tween.EASE_OUT)
	t.tween_property(black_screen, "color", Color(0,0,0,1), 0.7)
	await t.finished
	
	level.queue_free()
	remove_child(playerholder)
	match current_lvl:
		_:
			inst = level_warehouse.instantiate()
	level = inst
	add_child(inst)
	enter_next_lvl()
