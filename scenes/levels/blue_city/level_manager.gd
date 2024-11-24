extends Node2D
class_name LevelManager

## THESE SIGNALS MOVED TO EventBus
#signal level_cleared ## this is for the state when the last enemy dies
#signal exit_door_interacted ## this is state for when player goes through exit door
## emitted by exit door
enum RoomType {
	Normal, ## default room type, enemies present
	Rest, ## safe zone, upgrade station
	Boss, ## special room, boss present
	Other, ## for other room types
}

@export var room_type: RoomType = RoomType.Normal

var room_preset: RoomPreset = null:
	set(val):
		room_preset = val
		if not children_given_preset:
			await ready
			give_children_room_preset(val)
			children_given_preset = true
		else:
			printerr("LevelManager's room preset was updated again?")
var children_given_preset: bool = false

@onready var chest_rune_holder: ChestRuneHolder = $ChestRuneHolder
@onready var enemy_holder: EnemyHolder = $NormalEnemyHolder
@onready var elite_holder: EnemyHolder = $EliteEnemyHolder

@onready var starting_pos_marker: Marker2D = $StartingPos
@onready var starting_pos: Vector2 = starting_pos_marker.global_position
@onready var exit_door: ExitDoor = $ExitDoor


func give_children_room_preset(preset: RoomPreset) -> void: ## assigned by dungeon holder
	enemy_holder.num_of_enemies = preset.num_of_enemies
	elite_holder.num_of_enemies = preset.num_of_elites
	
	enemy_holder.hp_scaling = preset.enemy_HP_scaling
	elite_holder.hp_scaling = preset.enemy_HP_scaling
	
	chest_rune_holder.min_chest_spawns = preset.min_rune_chests
	chest_rune_holder.max_chest_spawns = preset.max_rune_chests
	chest_rune_holder.initialize_chests()
	
	enemy_holder.spawn_enemies(preset.normal_enemies_info)
	elite_holder.spawn_enemies(preset.elite_enemies_info)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	EventBus.enemy_died.connect(_enemy_dead)
	exit_door.local_exit_door_interacted.connect(_on_local_exit_door_interacted)
	
	await get_tree().physics_frame
	if EnemyAiManager.enemies_alive <= 0 and room_type != RoomType.Boss:
		_level_is_cleared()
	if room_type == RoomType.Boss:
		EventBus.boss_fight_ended.connect(_level_is_cleared)


func _enemy_dead(type: BaseEnemy) -> void:
	print_debug("called this")
	EnemyAiManager.enemies_alive -= 1
	if type is NormalEnemy:
		if type.is_small_drone:
			EnemyAiManager.small_drones -= 1
	if EnemyAiManager.enemies_alive <= 0:
		_level_is_cleared()


func _level_is_cleared() -> void:
	exit_door.open()
	chest_rune_holder.open_all_chest_rune()
	match room_type:
		RoomType.Normal:
			EventBus.level_cleared.emit("ENEMIES CLEARED")
		RoomType.Rest: 
			EventBus.level_cleared.emit("SAFEZONE")
		RoomType.Boss: 
			EventBus.level_cleared.emit("BOSS DEFEATED")
		_: 
			EventBus.level_cleared.emit("DOOR OPEN")


func _on_local_exit_door_interacted() -> void:
	EventBus.exit_door_interacted.emit()
