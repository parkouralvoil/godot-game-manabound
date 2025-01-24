extends PanelContainer
class_name StatsWindow


var tracked_char_resource: CharacterResource = null:
	set(val):
		tracked_char_resource = val
		if val:
			change_stats(val)

## Basic stats labels
@onready var hp: Label = %hp
@onready var atk: Label = %atk
@onready var ep: Label = %ep
@onready var chr: Label = %chr

## Special stats labels
@onready var spd: Label = %spd
@onready var rel: Label = %rel
@onready var firerate: Label = %firerate
@onready var ammo: Label = %ammo


func _ready() -> void:
	visibility_changed.connect(update_stats)


func change_stats(cr: CharacterResource) -> void:
	var s: CharacterStats = cr.stats
	hp.text = str(s.max_hp)
	atk.text = str(s.atk)
	ep.text = str(s.ep)
	chr.text = str(s.chr) + "%"
	
	spd.text = str(s.SPD)
	rel.text = "%ss" % str(s.reload_time)
	firerate.text = str(s.firerate)
	ammo.text = str(s.max_ammo)

func update_stats() -> void:
	if tracked_char_resource:
		change_stats(tracked_char_resource)
