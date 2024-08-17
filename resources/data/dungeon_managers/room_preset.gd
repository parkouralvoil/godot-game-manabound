extends Resource
class_name RoomPreset

@export var preset_name: String = "name"
@export_category("Normal Enemies")
@export var num_of_enemies: int = 1
@export_category("Chance to spawn") ## gets average then divides
@export var autobow: float = 5
@export var orb: float = 3
@export var laser: float = 3
@export var dronefactory: float = 1


@export_category("Elite Enemies")
@export var num_of_elites: int = 1
@export_category("Chance to spawn")
@export var machinegun: float = 1

@export_category("Speical Interactables")
@export var HP_potion_present: bool = false

@export_category("Specific Room (leave blank for normal)")
@export var room: PackedScene
