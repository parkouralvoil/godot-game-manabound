extends Resource
class_name PlayerInventory

signal number_of_runes_changed
signal total_orbs_changed ## for level summary
signal current_orbs_changed ## for team info menu group

var total_orbs_collected: int = 0:
	set(val):
		total_orbs_collected = val
		total_orbs_changed.emit() ## for level summary
var mana_orbs: int = 0:
	set(val):
		if val > mana_orbs:
			total_orbs_collected += (val - mana_orbs)
		mana_orbs = val
		current_orbs_changed.emit(val)

var rune_HP: int = 0:
	set(val):
		rune_HP = val
		number_of_runes_changed.emit()
var rune_ATK: int = 0:
	set(val):
		rune_ATK = val
		number_of_runes_changed.emit()
var rune_EP: int = 0:
	set(val):
		rune_EP = val
		number_of_runes_changed.emit()
var rune_CHR: int = 0:
	set(val):
		rune_CHR = val
		number_of_runes_changed.emit()
	
var stat_runes: int = 0:
	set(val):
		stat_runes = val
		number_of_runes_changed.emit()

var HP_increase: int = 1
var ATK_increase: int = 1
var EP_increase: int = 3
var CHR_increase: int = 10

## TEMP: gonna have inventory handle upgrading stats for now
## ideally, it'd be responsibility of an UpgradeModel, but im still thinkin

func reset_inventory() -> void:
	mana_orbs = 0
	rune_ATK = 0
	rune_CHR = 0
	rune_EP = 0
	rune_HP = 0

func use_rune_HP(stats: CharacterStats) -> void:
	assert(stats, "PlayerInventory: Missing stats param")
	if rune_HP > 0:
		stats.max_hp += HP_increase
		stats.hp += HP_increase
		rune_HP -= 1


func use_rune_ATK(stats: CharacterStats) -> void:
	assert(stats, "PlayerInventory: Missing stats param")
	if rune_ATK > 0:
		stats.atk += ATK_increase
		rune_ATK -= 1


func use_rune_EP(stats: CharacterStats) -> void:
	assert(stats, "PlayerInventory: Missing stats param")
	if rune_EP > 0:
		stats.ep += EP_increase
		rune_EP -= 1


func use_rune_CHR(stats: CharacterStats) -> void:
	assert(stats, "PlayerInventory: Missing stats param")
	if rune_CHR > 0:
		stats.chr += CHR_increase
		rune_CHR -= 1

func use_stat_rune(stats: CharacterStats, chosen_stat: String) -> void:
	if stat_runes <= 0:
		return
	stat_runes -= 1
	match chosen_stat:
		_:
			stats.atk += ATK_increase