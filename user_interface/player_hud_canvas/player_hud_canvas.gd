extends CanvasLayer
class_name PlayerHudCanvas

@export var dungeon_data: DungeonData
@export var player_info: PlayerInfoResource
@export var inventory: PlayerInventory
@export var selected_team_info: SelectedTeamInfo

@onready var blood_overlay: BloodOverlay = $BloodOverlay
@onready var game_info_hud: GameInfoHud = $GameInfoHud
@onready var team_hud: TeamHud = $TeamHud

func _ready() -> void:
	assert(dungeon_data)
	assert(player_info)
	assert(inventory)
	initialize_hud_children()
	print_debug("%s: initialize_hud_children done" % name)
	

func initialize_hud_children() -> void:
	blood_overlay.initialize(player_info)
	game_info_hud.initialize(inventory, dungeon_data)
	team_hud.initialize(player_info, selected_team_info)
