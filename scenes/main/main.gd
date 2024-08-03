extends Node2D
class_name Main # handles loading levels, saving player, etc.

const level_warehouse: PackedScene = preload("res://scenes/levels/blue_city/city_warehouse.tscn")
const level_TEST: PackedScene = preload("res://scenes/levels/blue_city/city_TEST.tscn")
var enemy_chance: float = 0 :
	set(value):
		enemy_chance = clampf(value, 0, 1)
var enemy_chance_scaling: float = 0.1

@onready var playerholder: Node2D = $PlayerHolder
@onready var level: LevelManager #= get_child(0) ## REMEMBERRRRRRRRRRRRRRRRRRRRRRRR
@onready var camera: PlayerCamera = $PlayerCamera
@onready var black_screen: ColorRect = $MainCanvas/Blackscreen 
@onready var popup_indicator: PopupIndicator = $MainCanvas/Popup_indicator


func _ready() -> void:
	#remove_child(playerholder)
	popup_indicator.hide()
	EventBus.go_next_lvl.connect(load_next_lvl)
	if not level:
		load_next_lvl(null)
	else:
		enter_next_lvl()

#print_orphan_nodes()
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
	popup_indicator.hide()
	var inst: LevelManager
	var t: Tween = create_tween()
	enemy_chance += enemy_chance_scaling
	black_screen.show()
	t.set_ease(Tween.EASE_OUT)
	EventBus.clear_abilities.emit()
	t.tween_property(black_screen, "color", Color(0,0,0,1), 0.5)
	await t.finished
	
	if level:
		level.level_cleared.disconnect(level_cleared_main)
		level.queue_free()
	remove_child(playerholder)
	match current_lvl:
		_:
			inst = level_warehouse.instantiate()
	level = inst
	level.level_cleared.connect(level_cleared_main)
	add_child(inst)
	enter_next_lvl()


func level_cleared_main() -> void:
	popup_indicator.show_lvl_cleared()
	await get_tree().create_timer(0.15).timeout
	EnemyAiManager.call_attract_orbs.emit()
