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


func open_all_chest_rune() -> void: ## called by level manager
	for chest in chest_array:
		chest.open_chest_rune()


## chest rune holder purpose:
"""
- START: set number of chests available to match current cycle (1-3, 3-5, 5-7)
- AFTER COMBAT: open all chests
	- holder is responsible of doing RNG to decide which rune is assigned to the chest
	- chest will spawn the rune and make it "pop out"
"""

## TODO: after chest and runes work,
"""
1. inventory (model)
2. upgrade stats menu (view)
	- thru button that only shows after combat done
3. check if dmg is updated properly
"""
