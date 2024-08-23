extends Control
class_name MenuManager


var current_menu_opened: Control = null
var level_up_available: bool

@onready var team_info: TeamInfoMenuGroup = $TeamInfoMenuGroup
@onready var preset_choice_window: ChoosePresetMenu = $PresetChoiceWindow
@onready var upgrade_stats_menu: UpgradeStatsMenu = $UpgradeStatsMenu

## (eventually need to redo TeamInfoMenuGrp using tab containers....)

## called by main
func initialize_menus(dungeon: DungeonData,
		selected_team_info: SelectedTeamInfo,
		inv: PlayerInventory,
) -> void:
	team_info.initialize_team_info(selected_team_info)
	preset_choice_window.initialize_preset_window(dungeon)
	upgrade_stats_menu.initialize_stats_menu(selected_team_info, inv)
	print("MenuManager: initialize menu done")


func _ready() -> void:
	EventBus.upgrade_stats_pressed.connect(switch_current_menu.bind(upgrade_stats_menu))
	
	team_info.hide()
	team_info.exit_menu.connect(close_menu)
	upgrade_stats_menu.exit_menu.connect(close_menu)
	preset_choice_window.hide()


func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("shop_key") 
			and current_menu_opened != team_info
			and not preset_choice_window.visible):
		switch_current_menu(team_info)
	
	## opening lvl menu is done thru button
	
	if event.is_action_pressed("esc") and current_menu_opened:
		close_menu()


func switch_current_menu(_menu: Control) -> void:
	if current_menu_opened:
		current_menu_opened.hide()
	current_menu_opened = _menu
	current_menu_opened.show()
	pause_game()


func close_menu() -> void:
	current_menu_opened.hide()
	unpause_game()
	current_menu_opened = null


func pause_game() -> void:
	get_tree().paused = true


func unpause_game() -> void:
	get_tree().paused = false
