extends TextureRect
class_name DebuffIndicator

@export var crystalized: AtlasTexture

@onready var HC: EnemyHealthComponent = get_parent().get_parent()
@onready var label_stack: Label = $Label_stacks
var debuff_counts: Array[int] = []

var current_debuff: CombatManager.Debuffs = CombatManager.Debuffs.NONE :
	set(value):
		current_debuff = _on_debuff_applied(value)

func _ready() -> void:
	debuff_counts.resize(CombatManager.Debuffs.size() )
	label_stack.text = "x" + str(debuff_counts[CombatManager.Debuffs.CRYSTALIZED])
	hide()

func _on_debuff_applied(new_debuff: CombatManager.Debuffs) -> CombatManager.Debuffs:
	match new_debuff:
		CombatManager.Debuffs.CRYSTALIZED:
			update_info()
		CombatManager.Debuffs.SUPERCONDUCT:
			pass
		_:
			update_info()
	return new_debuff


func update_info() -> void:
	debuff_counts[CombatManager.Debuffs.CRYSTALIZED] = HC.crystalize_effect.get_info(HC) # might be better as a signal
	if debuff_counts[CombatManager.Debuffs.CRYSTALIZED] <= 0:
		hide()
	else:
		show()
		label_stack.text = "x" + str(debuff_counts[CombatManager.Debuffs.CRYSTALIZED])
