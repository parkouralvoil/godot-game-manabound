extends EnemyHealthComponent
class_name SidepartRailgun_Health

## wait how is this updated this? apparently healthbar updates itself, but it uses get_parent.get_parent...
@onready var healthbar: ProgressBar = $Healthbar


func _ready() -> void:
	box = $Box
	super()


func _final_damage_received(final_dmg: float) -> void:
	if e.health - final_dmg > 0:
		e.health -= final_dmg
		produce_energy(0.5)
	elif not is_dead:
		produce_energy(5)
		is_dead = true
		e.health = 0
		#EventBus.enemy_died.emit(e)
		#EnemyAiManager.spawn_orbs(global_position, e.mana_orbs_dropped)
		SoundPlayer.play_sound_2D(global_position, enemy_explosion_sfx, explosion_volume + 7, 1.1)
		e.make_impact()
		await get_tree().physics_frame ## HACK
		_sidepart_dead()
		#e.queue_free()


func _sidepart_dead() -> void:
	if e is SidepartRailgun:
		e.sidepart_destroyed()
	healthbar.hide()
	box.hide()
	crystalize_effect.clear()
	superconduct_effect.clear()
	element_indicator.element = CombatManager.Elements.NONE



func reconstruction_finished() -> void:
	is_dead = false
	e.health = e.max_health
	element_initial = CombatManager.Elements.NONE
	healthbar.show()
	box.show()
