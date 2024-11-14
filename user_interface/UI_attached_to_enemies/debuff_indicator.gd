extends TextureRect
class_name DebuffIndicator

## textures
@export var crystalized: AtlasTexture

@onready var label_stack: Label = $Label_stacks
var debuff_counts: Array[int] = []


func _ready() -> void:
	debuff_counts.resize(CombatManager.Debuffs.size() )
	label_stack.text = "x" + str(debuff_counts[CombatManager.Debuffs.CRYSTALIZED])
	hide()

func notify_debuff(new_debuff: CombatManager.Debuffs, count: int = 0) -> void:
	match new_debuff:
		CombatManager.Debuffs.CRYSTALIZED:
			update_crystalized_info(count)
		CombatManager.Debuffs.SUPERCONDUCT:
			pass
		_:
			pass


func update_crystalized_info(crystal_stacks: int) -> void:
	debuff_counts[CombatManager.Debuffs.CRYSTALIZED] = crystal_stacks
	if debuff_counts[CombatManager.Debuffs.CRYSTALIZED] <= 0:
		hide()
	else:
		show()
		label_stack.text = "x" + str(debuff_counts[CombatManager.Debuffs.CRYSTALIZED])
