extends PanelContainer
class_name UpgradeStatsWindow

var inventory: PlayerInventory:
	set(val):
		inventory = val
		if val:
			_update_rune_number()
			inventory.number_of_runes_changed.connect(_update_rune_number)
var stats: CharacterStats:
	set(val):
		stats = val
		if val:
			stats.stats_changed.connect(_update_stats)

## rune amts
@onready var label_hp_rune: Label = %HPamt
@onready var label_atk_rune: Label = %ATKamt
@onready var label_ep_rune: Label = %EPamt
@onready var label_chr_rune: Label = %CHRamt

## buttons
@onready var hp_rune_use: Button = %HPRuneUse
@onready var atk_rune_use: Button = %ATKRuneUse
@onready var ep_rune_use: Button = %EPRuneUse
@onready var chr_rune_use: Button = %CHRRuneUse

## stats
@onready var hp: Label = %hp_amt_stat
@onready var atk: Label = %atk_amt_stat
@onready var ep: Label = %ep_amt_stat
@onready var chr: Label = %chr_amt_stat


func _update_stats() -> void:
	hp.text = "%d" % stats.max_hp
	atk.text = "%d" % stats.atk
	ep.text = "%d" % stats.ep
	chr.text = "%d%%" % stats.chr


func _update_rune_number() -> void:
	var s: String = "x%d"
	_try_disable_use_buttons()
	label_hp_rune.text = s % inventory.rune_HP
	label_atk_rune.text = s % inventory.rune_ATK
	label_ep_rune.text = s % inventory.rune_EP
	label_chr_rune.text = s % inventory.rune_CHR


func _try_disable_use_buttons() -> void:
	hp_rune_use.disabled = (inventory.rune_HP <= 0)
	atk_rune_use.disabled = (inventory.rune_ATK <= 0)
	ep_rune_use.disabled = (inventory.rune_EP <= 0)
	chr_rune_use.disabled = (inventory.rune_CHR <= 0)


func _on_hp_rune_use_pressed() -> void:
	if inventory:
		inventory.use_rune_HP(stats)


func _on_atk_rune_use_pressed() -> void:
	if inventory:
		inventory.use_rune_ATK(stats)


func _on_ep_rune_use_pressed() -> void:
	if inventory:
		inventory.use_rune_EP(stats)


func _on_chr_rune_use_pressed() -> void:
	if inventory:
		inventory.use_rune_CHR(stats)
