extends EnemyHealthComponent
class_name SidepartRailgun_Health


@onready var healthbar: ProgressBar = $Healthbar ## wait how is this updates this?
@onready var HBox: BoxContainer = $Box


func _ready() -> void:
	healthbar.hide() ## phase 1


func _final_damage_received(final_dmg: float) -> void:
	## phase 1
	if e is SidepartRailgun:
		e.boss.take_boss_damage(final_dmg)
	## phase 2
	#if e.health - final_dmg > 0:
		#e.health -= final_dmg
		#produce_energy(0.5)
	#elif not is_dead:
		#produce_energy(3)
		#is_dead = true
		#EventBus.enemy_died.emit(e)
		#EnemyAiManager.spawn_orbs(global_position, e.mana_orbs_dropped)
		#SoundPlayer.play_sound_2D(global_position, enemy_explosion_sfx, explosion_volume + 7, 1.1)
		#e.make_impact()
		#e.queue_free()
