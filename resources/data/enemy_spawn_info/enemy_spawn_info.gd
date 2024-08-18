extends Resource
class_name EnemySpawnInfo
## currently unused
@export var scene: PackedScene

## given by preset:
var final_probability: float = 0 ## used for spawn calculations
var raw_chance: float ## used to compute final probability

## the issue is assigning the preset's raw chance to the correct EnemySpawnInfo

# temporarily, it can be managed by direct assignment

# but if say i wanna add more enemies, idk
