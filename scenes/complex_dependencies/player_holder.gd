extends Node2D
class_name PlayerHolder

@onready var p: Player = $Player ## lez think abt this, why should PlayerInfo be gotten from player
## like PlayerHolde should pass player_info to the stuff that need it noh
@onready var info: PlayerInfoResource = p.PlayerInfo

@onready var hp_label: Label = $Player/VBoxContainer/HP
@onready var ammo_label: Label = $Player/VBoxContainer/Ammo
@onready var charge_label: Label = $Player/VBoxContainer/Charge


func _ready() -> void:
	info.player_got_hit.connect(hp_change_red)


func hp_change_red() -> void:
	var red := Color(1, 0.3, 0.3)
	var t := create_tween()
	t.tween_property(hp_label, "modulate", Color(1, 1, 1), 1).from(red)


func _process(_delta: float) -> void:
	if not p:
		return
	## UI attached to player:
	hp_label.text = "HP: %d/%d" % [info.displayed_HP, info.displayed_MAX_HP]
	ammo_label.text = "Ammo: %d/%d" % [info.displayed_ammo, info.displayed_MAX_AMMO]
	update_current_charge()


func update_current_charge() -> void:
	var type: String
	match info.current_charge_type:
		PlayerInfoResource.ChargeTypes.CHARGE:
			type = "Charge"
		PlayerInfoResource.ChargeTypes.MANA:
			type = "Mana"
		PlayerInfoResource.ChargeTypes.ENERGY:
			type = "Energy"
	
	var format_string: String = "%s: %d/%d"
	charge_label.text = format_string % [type, snapped(info.displayed_charge, 1), info.displayed_MAX_CHARGE]
