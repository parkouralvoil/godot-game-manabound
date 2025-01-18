extends PanelContainer
class_name StatsWindow


var tracked_char_resource: CharacterResource = null:
	set(val):
		tracked_char_resource = val
		if val:
			change_stats(val)

## Basic stats labels
@onready var hp: Label = $MarginContainer/VBox/base_stats/stat_number/hp
@onready var atk: Label = $MarginContainer/VBox/base_stats/stat_number/atk
@onready var ep: Label = $MarginContainer/VBox/base_stats/stat_number/ep
@onready var chr: Label = $MarginContainer/VBox/base_stats/stat_number/chr

## Special stats labels
@onready var spd: Label = $MarginContainer/VBox/special_stats/stat_number/spd
@onready var rel: Label = $MarginContainer/VBox/special_stats/stat_number/rel
@onready var firerate: Label = $MarginContainer/VBox/special_stats/stat_number/firerate
@onready var ammo: Label = $MarginContainer/VBox/special_stats/stat_number/ammo


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
