extends Resource
class_name DungeonData
#region Comment Information
## make a UNIQUE resource of this for EACH dungeon has info of 
"""
- Cycle info
	- enemy HP scaling
	- chest spawn rates (runes and items)
- Area info
	- all room types available in each area of the dungeon
	- types of enemies that can spawn
- Level info
	- which room to use
	- what PRESET of enemies
"""

## this is the base script for all area info models, like
## dungeon_blueCity

## each dungeon has 3 areas
## each area has 10 levels and 1 unique boss
## 4 combat lvls (NORMAL/SPECIAL) > rest lvl > next 4 combat lvl > rest lvl > boss

## hence there has to be at least 8 different room types to reduce area repetition
"""
BlueCity, City:
NORMAL ROOMS, has the PRESETS below (these arent options, 
they just randomly picked once u choose a PRESET)

Warehouse
Hourglass (2 floors)
4 Rooms
Alley-way
U shaped


FIRST AREA, first 4 levels only have calm, normal, bridge, dwelling, bowless
next 4 levels doesnt have calm anymore, all modifiers available
how modifiers are chosen by game: 
- everything has an equal chance to appear


idea for presets:
Bowless: Mostly orbs and lasers, no autobows
"""

"""
SPECIAL ROOM (u can choose a guaranteed room like this):
Cornered [Small Room] = only elites spawn
Dwelling [Small Room] = CALM but small room 
Bridge [Horizontal Tunnel] = autobows and lasers
Tower [Verticality] = orbs and lasers
Factory [Warehouse] = dronefactories and machineguns
"""
#endregion

## DungeonHolder -> UI
signal combat_state_changed() # for show lvl up button
signal exit_door_interacted() # for showing preset menu

## UI -> DungeonHolder
signal preset_selected(preset: RoomPreset) # for loading next level with selected preset

enum RoomInfo {
	COMBAT,
	REST,
	BOSS,
}

@export_category("Dungeon Data")
@export var name: String = "Region"
@export var NormalRooms: Array[PackedScene]
@export var TESTPreset: Array[RoomPreset]
@export var EasyPresets: Array[RoomPreset]
@export var HardPresets: Array[RoomPreset]

var current_cycle: int:
	set(val):
		current_cycle = maxi(1, val)
		_update_cycle_info()
var current_room: int = 1:
	set(val):
		current_room = maxi(0, val)
var cycle_room_progression: int = 5 ## FINAL: 10

var available_presets: Array[RoomPreset]

@export_category("Debug Exports")
@export var initial_preset: RoomPreset ## FOR TESTING
var chosen_preset: RoomPreset: ## FOR TESTING
	get:
		assert(chosen_preset, "Chosen Preset is null")
		return chosen_preset
	set(val):
		chosen_preset = val
		_update_preset()

##  one for EasyPresets (first 4 lvls) and one for HardPresets (next 4 lvls)

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
	chosen_preset = initial_preset
	available_presets = EasyPresets
	current_cycle = 1


func _update_cycle_info() -> void: ## inside setter of cycle
	#print("cycle updated")
	match current_cycle:
		1:
			min_chest_spawns = 1
			max_chest_spawns = 3
			
			enemy_HP_scaling = 1
		2:
			min_chest_spawns = 3
			max_chest_spawns = 5
			
			enemy_HP_scaling = 2
		_: ## cycles 3 and above go here
			min_chest_spawns = 7
			max_chest_spawns = 9
			
			enemy_HP_scaling = 4
	_update_preset()
#endregion


#region Room functions
func start_room() -> void:
	current_room = 1


func go_next_room(new_preset: RoomPreset) -> void:
	current_room += 1
	print("current room: %d" % current_room)
	## FUTURE TODO: when i add Underground Shelter and Research Facility, 
	## cycle only changes after 10 rooms
	if current_room <= cycle_room_progression: 
		current_cycle = 1
		available_presets = EasyPresets ## HACK
	elif current_room <= cycle_room_progression * 2:
		current_cycle = 2
		available_presets = HardPresets
	else:
		current_cycle = 3
		available_presets = HardPresets
	chosen_preset = new_preset ## must be set after cycle is updated

func retrieve_next_room_info() -> RoomInfo: ## UNUSED
	var next_room: int = current_room + 1
	match next_room:
		5:
			return RoomInfo.COMBAT # rest
		9:
			return RoomInfo.COMBAT # rest
		10:
			return RoomInfo.COMBAT # boss
		_:
			return RoomInfo.COMBAT
#endregion


func _update_preset() -> void:
	chosen_preset.min_rune_chests = min_chest_spawns
	chosen_preset.max_rune_chests = max_chest_spawns
	chosen_preset.enemy_HP_scaling = enemy_HP_scaling
	chosen_preset.initialize_info()
	#print("preset: %s, max rune chests: %d" % [chosen_preset.preset_name, 
			#chosen_preset.max_rune_chests])


func get_preset_choices() -> Array[RoomPreset]: ## always return array of size 2
	var choices: Array[RoomPreset]
	var copy_available: Array[RoomPreset] = available_presets.duplicate(false) ## shallow copy
	## shallow copy means it wont duplicate recursively
	## it works here since im not modifying the elems, just removing
	#print("copy available = %s" % str(copy_available))
	if copy_available.size() > 0:
		choices.append(copy_available.pick_random() )
	if copy_available.size() - 1 > 0:
		copy_available.erase(choices[0])
		choices.append(copy_available.pick_random() )
	return choices
