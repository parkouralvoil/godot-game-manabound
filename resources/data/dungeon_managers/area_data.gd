extends Resource
class_name AreaData

@export_category("Area")
@export var area_name: String = "City"
@export_category("Normal Rooms")
@export var NormalRooms: Array[PackedScene]
@export_category("Special Levels")
@export var rest_lvl: int = 5
@export var boss_lvl: int = 11

@export_category("Array Room Presets")
@export var RestPresets: Array[RoomPreset] ## array of size 1
@export var EasyPresets: Array[RoomPreset]
@export var HardPresets: Array[RoomPreset]
@export var BossPreset: Array[RoomPreset] ## array of size 1

func update_available_presets(current_lvl: int) -> Array[RoomPreset]:
	var next_room: int = current_lvl + 1 ## available presets is for the next room
	print_debug("current lvl: %d" % current_lvl)
	if next_room == rest_lvl or next_room == rest_lvl * 2:
		return RestPresets
	elif next_room == boss_lvl:
		return BossPreset
	elif next_room < rest_lvl:
		return EasyPresets
	else:
		return HardPresets
