extends Resource
class_name PlayerInventory

signal number_of_runes_changed

var mana_orbs: int = 0 #50000

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

var HP_increase: int = 1
var ATK_increase: int = 3
var EP_increase: int = 5
var CHR_increase: int = 2

## TEMP: gonna have inventory handle upgrading stats for now
## ideally, it'd be responsibility of UpgradeModel, but im still thinkin

func use_rune_HP(stats: CharacterStats) -> void:
	assert(stats, "PlayerInventory: Missing stats param")
	if rune_HP > 0:
		stats.MAX_HP += HP_increase
		stats.HP += HP_increase
		rune_HP -= 1


func use_rune_ATK(stats: CharacterStats) -> void:
	assert(stats, "PlayerInventory: Missing stats param")
	if rune_ATK > 0:
		stats.ATK += ATK_increase
		rune_ATK -= 1


func use_rune_EP(stats: CharacterStats) -> void:
	assert(stats, "PlayerInventory: Missing stats param")
	if rune_EP > 0:
		stats.EP += EP_increase
		rune_EP -= 1


func use_rune_CHR(stats: CharacterStats) -> void:
	assert(stats, "PlayerInventory: Missing stats param")
	if rune_CHR > 0:
		stats.CHR += CHR_increase
		rune_CHR -= 1
