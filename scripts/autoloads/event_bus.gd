extends Node
## mainly for general stuff, dont put player_info signals here pls

## camera signals
signal camera_shake(strength: int) # emitted by player i think || used by camera

## UI and levels
signal level_loaded() # emitted by main || used by game_info
signal level_cleared(message: String) # emitted by level_manager || used by DungeonHolder, popup_indicator
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

signal interacted_signboard ## emitted by signboard, used by menu manager
signal interacted_credits ## emitted by credits_book, used by menu manager

## emitted by details in signboard, used by DungoenHolder
signal mainhub_departed(selected_expedition: AreaData)

## emitted by area_tutorial, used by character character_manager, player_input, team_hud
signal tutorial_team_restriction_set(level: int) 

## Emitted by dungeon_data | used by victory_screen
signal expedition_completed(msg: String)

## UI and UI
signal upgrade_stats_pressed()

## enemies
signal enemy_died(e: BaseEnemy) # emitted by enemies || used by level_manager

## boss
signal boss_fight_started(boss_node: Node2D) ## emitted by RailgunBoss || used by game UI
signal boss_fight_ended()

## energy generation (rn for Rogue)
signal energy_gen_from_enemy_got_hit(procs: float)
signal energy_gen_from_skills(procs: int)

## clear bullets
signal clear_abilities() # emitted by level_manager || used by projectiles like frost_nova/ice storm
## signal auto_collect_orbs()

## for mobile controls
signal swapped_character(current_index: int, max_index: int) # character manager, used by swap char button
signal can_ult_changed(can_ult: bool) # from player info.gd, used by ult button