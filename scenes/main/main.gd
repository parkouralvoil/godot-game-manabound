extends Node2D
class_name Main # handles saving player, etc.

## black screen colors
var transparent := Color(0,0,0,0)
var opaque := Color(0,0,0,1)

@onready var dungeon_holder: DungeonHolder = $DungeonHolder
@onready var playerholder: Node2D = $PlayerHolder
@onready var camera: PlayerCamera = $PlayerCamera
@onready var black_screen: ColorRect = $MainCanvas/Blackscreen 
@onready var popup_indicator: PopupIndicator = $MainCanvas/Popup_indicator


func _ready() -> void:
	dungeon_holder.previous_level_cleaned_up.connect(_remove_player_holder)
	dungeon_holder.next_level_loaded.connect(_enter_next_lvl)
	
	popup_indicator.hide()
	dungeon_holder.load_next_lvl()


func _enter_next_lvl(starting_pos: Vector2) -> void: ## should be in (fade_out) state before doing this
	if not has_node("PlayerHolder"):
		add_child(playerholder)
	
	var player: Player = playerholder.p
	camera.position_smoothing_enabled = false
	player.global_position = starting_pos
	camera.global_position = starting_pos
	
	await fade_in()
	camera.target_node = player
	camera.position_smoothing_enabled = true


func _remove_player_holder() -> void:
	if has_node("PlayerHolder"):
		remove_child(playerholder)


func fade_in() -> void: ## black screen go away
	var t: Tween = create_tween()
	t.set_ease(Tween.EASE_OUT)
	t.tween_property(black_screen, "color", transparent, 0.7).from(opaque)
	await t.finished
	black_screen.hide()


func fade_out() -> void: ## black screen appears
	popup_indicator.hide() ##incase player enters door before popup disappears completely
	var t: Tween = create_tween()
	t.set_ease(Tween.EASE_OUT)
	t.tween_property(black_screen, "color", opaque, 0.5).from(transparent)
	black_screen.show()
	await t.finished
