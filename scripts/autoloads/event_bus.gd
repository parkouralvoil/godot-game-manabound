extends Node
## mainly for general stuff, dont put player_info signals here pls

## camera signals
signal camera_shake(strength: int)

## enemies
signal enemy_died()

## energy generation (rn for Rogue)
signal energy_gen_from_enemy_got_hit(procs: float)
signal energy_gen_from_skills(procs: int)

## clear bullets
signal clear_abilities()
## signal auto_collect_orbs()
