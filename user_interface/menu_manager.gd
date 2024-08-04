extends Control
class_name MenuManager


var current_menu_opened: Control = null

@onready var team_info: Control = $TeamInfoMenuGroup

## track current character so switching stree to stats remains on witch

func _ready() -> void:
	hide()
	team_info.hide()
	team_info.exit_menu.connect(close_menu)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shop_key") and current_menu_opened != team_info:
		switch_current_menu(team_info)
	if event.is_action_pressed("esc") and current_menu_opened:
		close_menu()


func switch_current_menu(_menu: Control) -> void:
	if current_menu_opened:
		current_menu_opened.hide()
	current_menu_opened = _menu
	current_menu_opened.show()
	show()
	pause_game()


func close_menu() -> void:
	current_menu_opened.hide()
	current_menu_opened = null
	hide()
	unpause_game()


func pause_game() -> void:
	get_tree().paused = true


func unpause_game() -> void:
	get_tree().paused = false
