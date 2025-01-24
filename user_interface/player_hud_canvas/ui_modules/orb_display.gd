extends HBoxContainer
class_name UI_OrbDisplay

@export var player_inventory: PlayerInventory

@onready var label_orbs: Label = %OrbsAmt

func _ready() -> void:
	assert(player_inventory, "Missing player inventory export on %s" % name)
	player_inventory.current_orbs_changed.connect(_on_current_orbs_changed)
	_on_current_orbs_changed(player_inventory.mana_orbs)

func _on_current_orbs_changed(new_orbs: int) -> void:
	label_orbs.text = "%d" % new_orbs
