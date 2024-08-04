extends Resource
class_name SubscribePlayerHolder_To_UI

signal data_updated(data: Array[CharacterResource])

var char_data_array: Array[CharacterResource]:
	set(val):
		char_data_array = val
		data_updated.emit(val) ## UI


func assign_array(arr: Array[CharacterResource]) -> void: ## player holder
	char_data_array = arr
