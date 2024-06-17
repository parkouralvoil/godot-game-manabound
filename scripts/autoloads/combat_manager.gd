extends Node

# stores the elements custom type

enum Elements {
	NONE,
	LIGHTNING,
	ICE,
	FIRE,
}

enum Debuffs {
	NONE,
	CRYSTALIZED,
	SUPERCONDUCT, # reaction: Ice + Lightning
	# OVERLOAD, # fire + lightning
	# MELT, # fire + ice
	# BURNING # fire DoT
}

# parameters
var params: Dictionary = {
	Elements.NONE : Color(1, 1, 1)
	, Elements.LIGHTNING : Color(1, 1, 0.5)
	, Elements.ICE : Color(0.3, 0.9, 1)
	
	, "superconduct" : Color(0.5, 0.5, 1)
}
