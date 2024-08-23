extends Resource
class_name SkillTreeModel

## this is just a DATA MODEL thats
	## read by skill_tree scene
	## read by ability manager

## possible interactions:
	## when skill tree scene detects an upgrade
	## this resource attempts to buy it
		## so it alrdy has info of whether previous skill is unlocked and whether theres enough mana orbs

## ROOT NODE: Character info
	# must have Name and Description
## LEFT NODE: Basic attack info
## RIGHT NODE: Ult info

signal skill_node_bought ## for AM to connect to

const inventory: PlayerInventory = preload("res://resources/data/player_inventory/player_inventory.tres")

var root_node: SkillTreeNode = SkillTreeNode.new()
var left_nodes: Array[SkillTreeNode]
var right_nodes: Array[SkillTreeNode]

func _init() -> void:
	root_node.active = true
	create_subtree(left_nodes)
	create_subtree(right_nodes)
	left_nodes[0].active = true
	right_nodes[0].active = true
	
	left_nodes[0].parent = root_node
	right_nodes[0].parent = root_node


func create_subtree(node_array: Array[SkillTreeNode]) -> void:
	## PARENT HAS TO BE ASSIGNED BY THE TREE
	for i in range(4):
		var node := SkillTreeNode.new()
		if i != 0:
			node.max_lvl = 1
		node.name = str(i)
		node_array.append(node) ## NOTE: oh my lord i had this as "SkillTreeNode.new()" so node was ignored...


func attempt_buy_node(node: SkillTreeNode) -> bool: ## bool to check if buying was successful
	if check_if_can_buy(node):
		buy_node(node)
		return true
	else:
		return false


func buy_node(node: SkillTreeNode) -> void:
	if not node.active:
		node.active = true
	inventory.mana_orbs -= node.cost
	node.lvl = min(node.lvl + 1, node.max_lvl)
	node.cost = _cost_increase(node.cost)
	skill_node_bought.emit() ## this will tell AM when to do (update_skills)


func check_if_can_buy(node: SkillTreeNode) -> bool:
	return (inventory.mana_orbs >= node.cost 
			and node.lvl < node.max_lvl 
			and node.parent.active)


func _cost_increase(prev_cost: int) -> int:
	return (prev_cost * 2) + 100
