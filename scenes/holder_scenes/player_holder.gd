extends Node2D

@onready var p: Player = $Player

@onready var hp_label: Label = $Player/VBoxContainer/HP
@onready var ammo_label: Label = $Player/VBoxContainer/Ammo
@onready var charge_label: Label = $Player/VBoxContainer/Charge
@onready var blood_overlay: TextureRect = $HUD_elements/BloodOverlay

@onready var team_hud: TeamHud = $HUD_elements/TeamHud

func _ready() -> void:
	p.PlayerDamaged.connect(trigger_blood_overlay)
	team_hud.initialize_hud(p)


func _process(_delta: float) -> void:
	if not p:
		return
	## UI attached to player:
	hp_label.text = "HP: %d/%d" % [p.PlayerInfo.displayed_HP, p.PlayerInfo.displayed_MAX_HP]
	ammo_label.text = "Ammo: %d/%d" % [p.PlayerInfo.displayed_ammo, p.PlayerInfo.displayed_MAX_AMMO]
	update_current_charge(p.PlayerInfo)
	
	## HUD elements:
	


func update_current_charge(info: PlayerInfoResource) -> void:
	var type: String
	match info.current_charge_type:
		PlayerInfoResource.ChargeTypes.BURST:
			type = "Charge"
		PlayerInfoResource.ChargeTypes.PASSIVE:
			type = "Mana"
		_:
			type = "Energy"
	
	var format_string: String = "%s: %d/%d"
	charge_label.text = format_string % [type, snapped(info.displayed_charge, 1), info.displayed_MAX_CHARGE]
	
	if info.displayed_charge >= 100:
		charge_label.modulate = Color(1, 0.2, 0.2)
	elif info.displayed_charge >= 50:
		charge_label.modulate = Color(1, 1, 0.2)
	elif info.displayed_charge >= 1:
		charge_label.modulate = Color(1, 1, 1, 0.8)
	else:
		charge_label.modulate = Color(0.6, 0.6, 0.6, 0.8)


func trigger_blood_overlay() -> void:
	var color_transparent: Color = Color(1, 1, 1, 0)
	var color_visible: Color = Color(1, 1, 1, 1)
	var tween: Tween = create_tween()
	tween.tween_property(blood_overlay, "modulate", color_transparent, 1).from(color_visible)
