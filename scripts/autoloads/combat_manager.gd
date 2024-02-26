extends Node

# stores the elements custom type

enum Elements {
	NONE,
	LIGHTNING,
	ICE
}

# How elemental reactions r coded:
# once apply_reaction() is called
# superconduct() is called next
	# it inflicts the debuff effects
	# creates a timer to tree
	# after timer clears, effects are reverted
