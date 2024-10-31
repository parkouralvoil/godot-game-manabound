extends Node
class_name LevelSumamry

var player_inventory: PlayerInventory

static var enemies_killed: int = 0
static var orbs_collected: int = 0
static var rooms_entered: int = 0

func initialize_level_summary(_inv: PlayerInventory) -> void:
	player_inventory = _inv
	
	EventBus.enemy_died.connect(_update_enemies_killed.unbind(1))
	EventBus.exit_door_interacted.connect(_update_rooms_entered)
	EventBus.returned_to_mainhub.connect(reset_level_summary)
	player_inventory.total_orbs_changed.connect(_update_orbs_collected)


func reset_level_summary() -> void:
	enemies_killed = 0
	player_inventory.total_orbs_collected = 0
	orbs_collected = 0
	rooms_entered = 0


func _update_enemies_killed() -> void:
	enemies_killed += 1


func _update_rooms_entered() -> void:
	rooms_entered += 1


func _update_orbs_collected() -> void:
	orbs_collected = player_inventory.total_orbs_collected
