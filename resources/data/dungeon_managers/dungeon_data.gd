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
signal game_started() # to show preset menu at start/load

## UI -> DungeonHolder
signal preset_selected(preset: RoomPreset) # for loading next level with selected preset

@export_category("Debug Exports")
@export var force_test_preset: bool = false
@export var test_preset: RoomPreset
@export var force_lvl_index: int = 99

@export_category("Dungeon")
@export var dungeon_name: String = "Region"
@export_category("Area Datas")
@export var area_datas: Array[AreaData]
var area: AreaData

var available_presets: Array[RoomPreset]
var chosen_preset: RoomPreset


var current_cycle: int:
	set(val):
		current_cycle = maxi(0, val)
var current_room: int = 0:
	set(val):
		current_room = maxi(0, val)
var previous_level: PackedScene


var enemy_HP_scaling: float = 0
var min_chest_spawns: int = 1:
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
func start_cycle() -> void:
	assert(area_datas.size() > 0)
	area = area_datas[0]
	available_presets = area.EasyPresets
	current_cycle = 1
	game_started.emit()


func _update_cycle_info() -> void: ## inside setter of cycle
	#print("cycle updated")
	if current_cycle <= 1: ## Tutorial and first cycle/area
		min_chest_spawns = 1
		max_chest_spawns = 3
		enemy_HP_scaling = 1
	elif current_cycle == 2:
		min_chest_spawns = 3
		max_chest_spawns = 5
		enemy_HP_scaling = 3
	else: ## Cycle 3 and above
		min_chest_spawns = 7
		max_chest_spawns = 9
		enemy_HP_scaling = 5
#endregion


#region Room functions
func start_room() -> void:
	current_room = 0


func go_next_room(new_preset: RoomPreset) -> void:
	if current_room >= area.boss_lvl: ## go to next area
		current_cycle += 1
		current_room = 1
	else:
		current_room += 1
	print_debug("current room: %d" % current_room)
	var next_room: int = current_room + 1 ## available presets is for the next room
	if next_room < area.rest_lvl:
		available_presets = area.EasyPresets
	elif next_room == area.rest_lvl or next_room == area.rest_lvl * 2:
		available_presets = area.RestPresets
	else:
		available_presets = area.HardPresets
	
	#if current_room == 10:
	#	available_presets = BossPreset
	
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
	## elif current lvl is 4 or 9, return rest room
	## chosen preset will handle boss, since boss is a preset
	assert(area, "dungeon_data has no area_data")
	if chosen_preset.room:
		return chosen_preset.room
	
	var lvl_available: Array[PackedScene] = area.NormalRooms.duplicate(false)
	## TODO: available rooms shuold remove the last room in NormalROoms
	if force_lvl_index < area.NormalRooms.size():
		print_debug("FORCE LVL INDEX ON")
		previous_level = area.NormalRooms[force_lvl_index]
		return area.NormalRooms[force_lvl_index]
	
	if area.NormalRooms.size() > 1 and previous_level != null:
		lvl_available.erase(previous_level)
		previous_level = lvl_available.pick_random()
	else:
		previous_level = lvl_available.pick_random()
	return previous_level


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
