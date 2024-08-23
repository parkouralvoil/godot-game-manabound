extends MarginContainer
class_name UpgradeStatsTab


@onready var _char_window: CharacterWindow = $HBox/CharacterWindow
@onready var _upgrade_stats_window: UpgradeStatsWindow = $HBox/UpgradeStatsWindow


func initialize_windows(_inv: PlayerInventory, _char: CharacterResource) -> void:
	_char_window.tracked_char_resource = _char
	_upgrade_stats_window.inventory = _inv
	_upgrade_stats_window.stats = _char.stats
