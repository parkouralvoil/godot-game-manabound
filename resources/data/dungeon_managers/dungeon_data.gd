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
## blueCity_d
## DungeonManager_Flameheart
## DungeonManager_ManaHaven

## each dungeon has 3 areas
## BlueCity => City, Underground Shelter, Research Facility
## Flameheart => First Cavern, Demon Ruins, Mantle Mining Platform
## ManaHaven => Viridian Forest, Mushroom Grove, Starstruck Biome

## each area has 10 levels and 1 unique boss
## 4 combat lvls (NORMAL/SPECIAL) > rest lvl > next 4 combat lvl > rest lvl > boss

## hence there has to be at least 8 different room types to reduce area repetition
"""
BlueCity, City:
NORMAL ROOMS, has the PRESETS below (these arent options, they just randomly picked once u choose a PRESET)
Warehouse
Hourglass (2 floors)
4 Rooms
Alley-way
U shaped


FIRST AREA, first 4 levels only have calm, normal, bridge, dwelling, bowless
next 4 levels doesnt have calm anymore, all modifiers available
how modifiers are chosen by game: 
- everything has an equal chance to appear, EXCEPT for the 2 options given last room


PRESETS:
Calm: small number of enemies, VV
Normal: Mostly autobows, moderate lasers/energyorb/ rarely drone factory
Bowless: Mostly orbs and lasers, no autobows
Risky: NORMAL but much more enemies

Hard:
Elite: Less normal enemies spawn, but more elite enemies spawn
Swarm: Mostly dronefactories
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

enum RoomInfo {
	COMBAT,
	REST,
	BOSS,
}

@export_category("Dungeon Data")
@export var name: String = "Region"
@export var NormalRooms: Array[PackedScene]
@export var EasyPresets: Array[RoomPreset]
@export var HardPresets: Array[RoomPreset]

var current_cycle: int:
	set(val):
		current_cycle = maxi(1, val)
		_update_cycle_info()
var current_room: int = 1:
	set(val):
		current_room = maxi(0, val)
var available_presets: Array[RoomPreset] = EasyPresets
@export var chosen_preset: RoomPreset: ## FOR TESTING
	set(val):
		chosen_preset = val
		_update_preset()
## NOTE: im still not sure whats a good way to go about this, if i need to limit the available presets
## ALTERNATIVELY: i could just have 2 export vars of presets, one for Easy (first 4 lvls) and one for Hard (all lvls)

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


#region Cycle Functions
func start_cycle() -> void:
	current_cycle = 1


func go_next_cycle() -> void:
	current_cycle += 1
	## set enemy HP scaling here
	## set available presets


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


func go_next_room() -> void:
	current_room += 1
	if current_room >= 2: ## TESTING
		go_next_cycle()


func retrieve_next_room_info() -> RoomInfo: ## UNUSED
	var next_room = current_room + 1
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
