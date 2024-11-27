extends Node2D
class_name ItemHolder

@export_category("Item Packed Scenes")
var HP_Potion: PackedScene = preload("res://scenes/interactables/health_potion/health_potion.tscn")

## for spawning potions (and maybe other items in the future)
## DO NOT PUT UpgradeStation and ExitDoor HERE!!!

@onready var item_array: Array[Marker2D] = []

func spawn_HP_item() -> void: ## called by level manager
	var children_array: Array[Node] = get_children()
	children_array.shuffle()
	
	for child in children_array:
		if child is Marker2D:
			var potion: HealthPotionDrop = HP_Potion.instantiate()
			child.add_child(potion)
			break
