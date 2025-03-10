extends CanvasLayer
class_name PlayerHudCanvas

@export var dungeon_data: DungeonData
@export var player_info: PlayerInfoResource
@export var inventory: PlayerInventory
@export var selected_team_info: SelectedTeamInfo

@onready var blood_overlay: BloodOverlay = $BloodOverlay
@onready var game_info_hud: GameInfoHud = %GameInfoHud
@onready var team_hud: TeamHud = %TeamHud
@onready var gameover: GameOver = $GameoverScreen

func _ready() -> void:
	assert(dungeon_data)
	assert(player_info)
	assert(inventory)
	initialize_hud_children()
	print_debug("%s: initialize_hud_children done" % name)
	player_info.character_died.connect(_on_character_died.unbind(1))


func initialize_hud_children() -> void:
	blood_overlay.initialize(player_info)
	game_info_hud.initialize(inventory, dungeon_data)
	team_hud.initialize(player_info, selected_team_info)


func _on_character_died() -> void:
	if player_info.team_alive == 0:
		await get_tree().create_timer(0.8).timeout
		gameover.show_gameover_characters_dead()
