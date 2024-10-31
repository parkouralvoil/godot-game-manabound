extends Node2D
class_name Main # handles saving player, etc.

## main will be responsible for giving dungeon data
@export_category("TEMPORARY")
@export var main_dungeon_data: DungeonData
@export var main_selected_team_info: SelectedTeamInfo
@export var main_player_inventory: PlayerInventory

## black screen colors
var transparent := Color(0,0,0,0)
var opaque := Color(0,0,0,1)

@onready var dungeon_holder: DungeonHolder = $DungeonHolder
@onready var playerholder: PlayerHolder = $PlayerHolder
@onready var camera: PlayerCamera = $PlayerCamera

@onready var player_hud: CanvasLayer = $PlayerHudCanvas

@onready var black_screen: ColorRect = $MainCanvas/Blackscreen
@onready var menu_manager: MenuManager = $MainCanvas/MenuManager
@onready var level_summary: LevelSumamry = $LevelSummary


func _ready() -> void:
	assert(main_dungeon_data, "%s: missing MainDungeonData export" % name)
	assert(main_selected_team_info)
	assert(main_player_inventory)
	_update_children_data()
	
	player_hud.hide()
	
	dungeon_holder.previous_level_cleaned_up.connect(_remove_player_holder)
	dungeon_holder.next_level_loaded.connect(_enter_next_lvl)
	
	dungeon_holder.initialize_main_hub()
	#dungeon_holder.load_next_lvl()
	## STEPS: dungeon.load_next_lvl -> _enter_next_lvl -> fade in


func fade_in() -> void: ## black screen go away
	var t: Tween = create_tween()
	t.set_ease(Tween.EASE_OUT)
	t.tween_property(black_screen, "color", transparent, 0.7).from(opaque)
	await t.finished
	black_screen.hide()


func fade_out() -> void: ## black screen appears
	var t: Tween = create_tween()
	t.set_ease(Tween.EASE_OUT)
	t.tween_property(black_screen, "color", opaque, 0.5).from(transparent)
	black_screen.show()
	await t.finished


func _enter_next_lvl(starting_pos: Vector2) -> void: ## should be in (fade_out) state before doing this
	if not has_node("PlayerHolder"):
		add_child(playerholder)
	
	EventBus.level_loaded.emit()
	var player: Player = playerholder.p
	camera.position_smoothing_enabled = false
	player.global_position = starting_pos
	camera.global_position = starting_pos
	#print("player loaded with camera")
	
	player_hud.show()
	await fade_in()
	camera.target_node = player
	camera.position_smoothing_enabled = true
	#print_orphan_nodes()
	#print("orphan nodes printed")


func _remove_player_holder() -> void:
	if has_node("PlayerHolder"):
		remove_child(playerholder)


func _update_children_data() -> void:
	if dungeon_holder:
		dungeon_holder.dungeon_data = main_dungeon_data
	if menu_manager:
		menu_manager.initialize_menus(main_dungeon_data, main_selected_team_info,
				main_player_inventory) 
	level_summary.initialize_level_summary(main_player_inventory)
	DevConsole.dungeon_data = main_dungeon_data
	DevConsole.selected_team_info = main_selected_team_info
	DevConsole.inventory = main_player_inventory
