extends Node
## This autoload mostly serves for giving type-support to combat terms such as
	## Elements, Reactions, Debuffs
	

var overload_impact: PackedScene = preload("res://projectiles/fire_projectiles/overload_impact/overload_impact.tscn")

enum Elements {
	NONE,
	LIGHTNING,
	ICE,
	FIRE,
}

enum Debuffs {
	NONE,
	CRYSTALIZED,
	SUPERCONDUCT,
	# BURNING # fire DoT
}

enum Reactions {
	NONE,
	MELT, # ice + fire
	SUPERCONDUCT, # ice + lightning
	OVERLOAD, # fire + lightning
}

# parameters
var params: Dictionary = {
	Elements.NONE : Color(1, 1, 1)
	, Elements.LIGHTNING : Color(1, 1, 0.5)
	, Elements.ICE : Color(0.3, 0.9, 1)
	, Elements.FIRE : Color(1, 0.4, 0.4)
	, "superconduct" : Color(0.5, 0.5, 1)
	, "melt" : Color(1, 0.5, 1)
	, "overload" : Color(1, 0.5, 0)
}


func determine_reaction(elem_A: Elements, elem_B: Elements) -> Reactions:
	if ((elem_A == Elements.ICE and elem_B == Elements.FIRE) or 
		(elem_B == Elements.ICE and elem_A == Elements.FIRE)):
		return Reactions.MELT
	elif ((elem_A == Elements.ICE and elem_B == Elements.LIGHTNING) or 
		(elem_B == Elements.ICE and elem_A == Elements.LIGHTNING)):
		return Reactions.SUPERCONDUCT
	elif ((elem_A == Elements.FIRE and elem_B == Elements.LIGHTNING) or 
		(elem_B == Elements.FIRE and elem_A == Elements.LIGHTNING)):
		return Reactions.OVERLOAD
	else:
		return Reactions.NONE
