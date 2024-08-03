extends RefCounted ## by default if it doesnt extend to anyhting, it goes here
class_name SkillTreeNode

signal node_updated ## need to communicate to button

var name: String
var description: String = "description"
var lvl: int = 0:
	set(val):
		lvl = val
		node_updated.emit()
var max_lvl: int = 0:
	set(val):
		max_lvl = val
		node_updated.emit()

var parent: SkillTreeNode = null:
	set(node):
		if node == self:
			print("Cannot set stree node as its own parent!, %s" % node.name)
			parent = null
		else:
			parent = node

var active: bool = false

var cost: int = 100
## how should this be assigne... by the AM as well?
## The AM already gives the name and description, it could also assign the initial cost too...

## during a new game, the AM's resets the cost back to default, so no need to store initial cost here
