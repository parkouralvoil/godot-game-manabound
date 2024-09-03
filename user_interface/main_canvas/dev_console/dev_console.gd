extends CanvasLayer

var history: Array[String] = []
var history_index: int = -1


## Where in the list of possible matches are we
var autocomplete_index: int = 0
## All methods that are viable for autocomplete
var autocomplete_methods: Array = []
## Track if that last input was related to autocomplete
var last_input_was_autocomplete: bool = false
## Store matches of the last autocomplete so that the search doesn't have to be repeated
## when Tab is pressed multiple times
var prev_autocomplete_matches: Array = []

@onready var console: RichTextLabel = %Console
@onready var text_input: LineEdit = %TextInput
@onready var exit_button: Button = %exit

#region DevConsole inner functions
func _ready() -> void:
	exit_button.pressed.connect(func() -> void: hide())
	## Get the list of methods defined in the current script without including any inherited functions
	autocomplete_methods = (get_script()
			.get_script_method_list()
			.map(func(x: Dictionary) -> String: return x.name)
			.filter(func(method_name: String) -> bool: return method_name[0] != '_')
			)
	print_debug(autocomplete_methods)
	hide()


func _run_command(cmd: String) -> void:
	## Create an Expression instance
	var expression := Expression.new()
	var parse_error := expression.parse(cmd)
	#print_debug(parse_error)
	if parse_error != OK:
		## Code here to log and format the error to the dev console
		_print_console(expression.get_error_text())
		return

	## First parameter is for variables, 
		# which I don't need, so I just pass an empty array as the first parameter
	## Second parameter is the object 
		# that can provide additional context to the command
	## In this case, I have "reload" defined in the same script as my Expression, so I just pass "self"
	var result: Variant = expression.execute([], self) # has to be DYNAMIC type
	if expression.has_execute_failed():
		_print_console("[color=red]ERROR:[/color] Unknown command \"%s\"" % cmd)
		return
	if result is String:
		_print_console(result)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed('_dev_console_enter'):
		history.push_front(text_input.text)
		_run_command(text_input.text)
		history_index = -1
		text_input.clear()
		text_input.release_focus()
	elif not visible:
		return
	
	if event.is_action_pressed('_dev_console_prev'):
		if history.size() == 0:
			return
		history_index = clamp(history_index + 1, 0, history.size() - 1)
		text_input.text = history[history_index]
		# Hack to make the caret go to the end of the line
		# If I ever have a line of code over 100k characters, please send help
		text_input.caret_column = 100000
	elif event.is_action_pressed('_dev_console_next'):
		if history.size() == 0:
			return
		history_index = clamp(history_index - 1, 0, history.size() - 1)
		text_input.text = history[history_index]
		text_input.caret_column = 100000
	
	# Track if the user has hit any inputs that should reset the autocomplete index
	if event.is_action_pressed("_dev_console_autocomplete") and text_input.has_focus():
		_autocomplete()
		print_debug("pressed tab")
	last_input_was_autocomplete = Input.is_action_just_pressed('_dev_console_autocomplete') \
	or Input.is_action_just_released('_dev_console_autocomplete') \
	and text_input.has_focus()


func _autocomplete() -> void:
	var matches: Array = []
	var match_string: String = text_input.text
	# Run through matches for the last string if the user is stepping through autocomplete options
	if last_input_was_autocomplete:
		print_debug("== 0")
		matches = prev_autocomplete_matches
	# Step through all possible matches if no input string
	elif match_string.length() == 0:
		matches = autocomplete_methods
	# Otherwise check if each possible method begins with the user string
	else:
		for method in autocomplete_methods:
			if method.begins_with(match_string):
				matches.append(method)
	# Store matches string for later
	prev_autocomplete_matches = matches
	# Nothing to return if no matches
	if matches.size() == 0:
		return
	# Go to the next possible autocomplete option if the user is Tabbing through options
	if last_input_was_autocomplete:
		autocomplete_index = wrapi(
				autocomplete_index + 1,
				0,
				matches.size()
				)
	else:
		autocomplete_index = 0
	# Populate console input with match
	text_input.text = matches[autocomplete_index] + "()"
	print_debug("NICE")
	text_input.caret_column = 100000


func _print_console(string: String) -> void:
	console.append_text(string + "\n")
#endregion

## functions usable in console
## Reload the current scene
func restart_main() -> String:
	get_tree().reload_current_scene() ## it complete restarts the scene, cuz im using the main scene now
	return "restart_main()\n\t[color=#7FFFD4]- Main scene restarted.[/color]"


## ideas (keep them simple pls)
"""
- set_current_char_stats("ATK", 1)
- give_runes("ATK", 1)
- give_mana_orbs(5000)
- set_dungeon_level(6)
- skip_dungeon_level()
"""
