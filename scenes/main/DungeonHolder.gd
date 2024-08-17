extends Node2D
class_name DungeonHolder
"""
this handles the ff:
	- loading levels
	- stores DM's which have the packedscenes of the levels they have
"""

signal level_ready

@export var current_DM: DungeonManager

## for now its Dungeon Manager -> Level Manager
## but later it might become Dungeon Manager -> Area Manager -> Level Manager

var current_level: LevelManager
