extends Node
## mainly for general stuff, dont put player_info signals here pls

## camera signals
signal camera_shake(strength: int) # emitted by player i think || used by camera

## UI and levels
signal level_loaded() # emitted by main || used by game_info
signal level_cleared(is_combat_room: bool) # emitted by level_manager || used by DungeonHolder, popup_indicator
signal exit_door_interacted() # emitted by level_manager || used by DungeonHolder, UI

## game over
signal return_to_base_pressed ## emitted by PauseMenu || used by gameover_screen
signal returned_to_mainhub ## final state of gameover

## interactable
signal interactable_detected(component: Interactable)

signal interactable_held
signal interactable_finished
	## for "hold E to ..." like downed char, this stops player

signal interacted_upgraded_station

## UI and UI
signal upgrade_stats_pressed()

## enemies
signal enemy_died(e: BaseEnemy) # emitted by enemies || used by level_manager

## energy generation (rn for Rogue)
signal energy_gen_from_enemy_got_hit(procs: float)
signal energy_gen_from_skills(procs: int)

## clear bullets
signal clear_abilities() # emitted by level_manager || used by projectiles like frost_nova/ice storm
## signal auto_collect_orbs()
