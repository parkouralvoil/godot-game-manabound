extends Node

# stores the elements custom type

enum Elements {
	NONE
	, LIGHTNING
	, ICE
}

# How elemental reactions r coded:
# once apply_reaction() is called
# superconduct() is called next
	# it inflicts the debuff effects
	# creates a timer to tree
	# after timer clears, effects are reverted

# parameters
var params: Dictionary = {
	Elements.NONE : Color(1, 1, 1)
	, Elements.LIGHTNING : Color(1, 1, 0.5)
	, Elements.ICE : Color(0.3, 0.9, 1)
	
	, "superconduct" : Color(0.5, 0.5, 1)
}
