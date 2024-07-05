extends Node
## mainly for general stuff, dont put player_info signals here pls
## level
signal go_next_lvl(current_lvl: Node2D)

## camera signals
signal camera_shake(strength: int)

## enemies
signal enemy_lost_5_hp(procs: int)
signal enemy_died()


## clear bullets
signal clear_abilities()
