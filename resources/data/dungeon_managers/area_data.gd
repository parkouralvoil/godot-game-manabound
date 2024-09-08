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
