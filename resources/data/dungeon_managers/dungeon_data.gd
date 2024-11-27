extends Resource
class_name DungeonData
"""
- Dungeon (Cycle) info
	- enemy HP scaling
	- chest spawn rates (runes and items)
- Level info
	- which room to use
	- what PRESET of enemies
- Area info
	- presets available
	- normal rooms available
	- dictates when rest and boss lvl is
"""

## DungeonHolder -> UI
signal combat_state_changed() # for show lvl up button
signal exit_door_interacted() # for showing preset menu after battle
signal main_hub_loaded() # to tell certain UIs to change when at main hub
signal game_started(starting_preset: RoomPreset) # to begin game

## UI -> DungeonHolder
signal preset_selected(preset: RoomPreset) # for loading next level with selected preset

@export_category("Debug Exports")
@export var force_test_preset: bool = false
@export var test_preset: RoomPreset

@export_category("Dungeon")
@export var dungeon_name: String = "Region"
@export_category("Area Datas")
@export var area_datas: Array[AreaData]
var area: AreaData

var available_presets: Array[RoomPreset]
var chosen_preset: RoomPreset


var current_area_index: int:
	set(val):
		current_area_index = maxi(0, val)
var current_room: int = 0:
	set(val):
		current_room = maxi(0, val)
var previous_room: PackedScene


var enemy_HP_scaling: float = 0
var min_chest_spawns: int = 2:
	set(value):
		min_chest_spawns = max(value, 0)
		if max_chest_spawns < min_chest_spawns:
			max_chest_spawns = max(value, 0)
var max_chest_spawns: int = 3:
	set(value):
		max_chest_spawns = max(value, 0)
		if max_chest_spawns < min_chest_spawns:
			min_chest_spawns = max(value, 0)

## state of the lvl:
var state_in_combat: bool = false:
	set(val):
		state_in_combat = val
		combat_state_changed.emit()


#region Cycle Functions
func start_cycle(selected_expedition: AreaData) -> void:
	state_in_combat = true
	area = selected_expedition
	if area is AreaTutorialData:
		EventBus.tutorial_team_restriction_set.emit(1)
	else:
		EventBus.tutorial_team_restriction_set.emit(3)
	assert(area.EasyPresets.size() >= 1)
	chosen_preset = area.EasyPresets[0]
	preset_selected.emit(chosen_preset)
	start_room()


func _update_cycle_info() -> void: ## inside setter of cycle
	#print("cycle updated")
	#if current_area_index <= 1: ## Tutorial and first cycle/area
	min_chest_spawns = 2
	max_chest_spawns = 3
	enemy_HP_scaling = 1
	#elif current_area_index == 2:
		#min_chest_spawns = 3
		#max_chest_spawns = 5
		#enemy_HP_scaling = 3
	#else: ## Cycle 3 and above
		#min_chest_spawns = 7
		#max_chest_spawns = 9
		#enemy_HP_scaling = 5
#endregion


#region Room functions
func start_room() -> void:
	current_room = 0 ## since the code adds 1 every time go next room is called
	print_debug("i was called")


func end_expedition() -> void: ## called by dungeon_holder
	if area is AreaTutorialData: ## tutorial
		var msg := "You have finished the tutorial. Nice!"
		EventBus.expedition_completed.emit(msg)
	else:
		var msg := "It's not yet the end for this expedition.\nTo be continued..."
		EventBus.expedition_completed.emit(msg)


func go_next_room(new_preset: RoomPreset) -> void:
	if chosen_preset and chosen_preset in area.BossPreset:
		if area is AreaTutorialData: ## tutorial
			return
		else:
			return
	else:
		current_room += 1
	available_presets = area.update_available_presets(current_room)
	
	chosen_preset = new_preset ## must be set after cycle is updated
	_update_cycle_info()
	_update_preset(chosen_preset)
#endregion


func _update_preset(_preset: RoomPreset) -> void:
	_preset.min_rune_chests = min_chest_spawns
	_preset.max_rune_chests = max_chest_spawns
	_preset.enemy_HP_scaling = enemy_HP_scaling
	_preset.initialize_info()
	#print("preset: %s, max rune chests: %d" % [chosen_preset.preset_name, 
			#chosen_preset.max_rune_chests])


func get_level() -> PackedScene:
	assert(area, "dungeon_data has no area_data")
	if chosen_preset.room: ## if preset has specific room, go there
		return chosen_preset.room
	
	var rooms_available: Array[PackedScene] = area.NormalRooms.duplicate(false)
	var selected_room: PackedScene = null
	
	if area.NormalRooms.size() > 1 and previous_room != null:
		rooms_available.erase(previous_room)
		selected_room = rooms_available.pick_random()
	else:
		selected_room = rooms_available.pick_random()
	previous_room = selected_room
	return selected_room


func get_preset_choices() -> Array[RoomPreset]: ## always return array of size 2
	var choices: Array[RoomPreset] = [null]
	var copy_available: Array[RoomPreset] = available_presets.duplicate(false) ## shallow copy
	## shallow copy means it wont duplicate recursively
	## it works here since im not modifying the elems, just removing
	#print("copy available = %s" % str(copy_available))
	if copy_available.size() > 0:
		choices[0] = copy_available.pick_random()
	if copy_available == area.RestPresets:
		return choices
	if not force_test_preset:
		if copy_available.size() - 1 > 0:
			copy_available.erase(choices[0])
			choices.append(copy_available.pick_random())
	else:
		choices.append(test_preset)
	return choices
