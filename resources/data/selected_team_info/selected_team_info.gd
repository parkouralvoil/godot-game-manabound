extends Resource
class_name SelectedTeamInfo

signal data_updated(data: Array[CharacterResource])

## TESTING, once i add more chars i need to remove @export
@export var TEMP_char_data_array: Array[CharacterResource]
var char_data_array: Array[CharacterResource]:
	get: ## HACK: cuz i dont have smthg that updates the data (aka the team selection menu)
		data_updated.emit(TEMP_char_data_array)
		return TEMP_char_data_array
	set(val):
		char_data_array = val
		data_updated.emit(val) ## UI

## used by TeamInfoMenuGroup, PlayerHolder's TeamHud
## updated by WIP (once i add new chars) team selection menu


func assign_array(arr: Array[CharacterResource]) -> void: ## UNUSED, will be used in the future
	char_data_array = arr
