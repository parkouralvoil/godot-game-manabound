extends Resource
class_name AreaData

signal area_completed

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

var completed: bool = false:
	set(val):
		completed = val
		if completed:
			area_completed.emit()
var _stack: int = 0

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

func shuffle_room_array() -> void:
	NormalRooms.shuffle()


func get_normal_room() -> PackedScene:
	var picked_room: PackedScene = NormalRooms[_stack]
	if _stack + 1 < NormalRooms.size():
		_stack += 1
	else:
		_stack = 0
	return picked_room
