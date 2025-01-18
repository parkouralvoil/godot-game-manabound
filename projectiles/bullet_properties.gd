extends RefCounted
class_name BulletProperties

"""
For easier compilation of bullet propeties
Use: pass this to "shoot" functions and done
"""

var final_damage: float	= 999	## final damage of bullet
var max_distance: float = 20	## how far the bullet travels
var speed: float		= 2		## how fast the bullet is
var ep: float			= 1		## EP of the bullet, mainly for future balancing

## ideas:
#var pierce_count: int		## how many times bullet can pierce. UNUSED
#var explosive: bool			## if bullet can explode