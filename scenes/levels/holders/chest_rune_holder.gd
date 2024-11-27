extends Node2D
class_name ChestRuneHolder

var min_chest_spawns: int = 7
var max_chest_spawns: int = 9

@onready var chest_array: Array[ChestRune]


func initialize_chests() -> void: ## called by level manager
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var chest_spawns: int = rng.randi_range(min_chest_spawns, max_chest_spawns)
	
	var children_array: Array[Node] = get_children()
	children_array.shuffle()
	
	for child in children_array:
		if not child is ChestRune:
			continue
		
		if chest_array.size() < chest_spawns:
			chest_array.append(child)
		else:
			child.disable_chest()

#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("1"): ## TESTING
		#open_all_chest_rune()

func open_all_chest_rune() -> void: ## called by level manager
	#print_debug("called open chests: ", chest_array)
	for chest in chest_array:
		chest.open_chest_rune()


func change_chests_to_HP() -> void:
	#print_debug("called change chests: ", chest_array)
	for chest in chest_array:
		#print_debug("inside loop")
		chest.drop_HP_rune = true


## chest rune holder purpose:
"""
- START: set number of chests available to match current cycle (1-3, 3-5, 5-7)
- AFTER COMBAT: open all chests
	- holder is responsible of doing RNG to decide which rune is assigned to the chest
	- chest will spawn the rune and make it "pop out"
"""
