extends TextureRect
class_name ElementIndicator

@export var lightning: AtlasTexture
@export var ice: AtlasTexture
@export var fire: AtlasTexture

@onready var HC: EnemyHealthComponent = get_parent().get_parent()

var element: CombatManager.Elements = CombatManager.Elements.NONE :
	set(value):
		element = _on_elem_change(value)

func _ready() -> void:
	assert(HC, "not there")
	element = HC.element_initial

func _on_elem_change(new_elem: CombatManager.Elements) -> CombatManager.Elements:
	#print(CombatManager.Elements.keys()[new_elem])
	match new_elem:
		CombatManager.Elements.NONE:
			hide()
		CombatManager.Elements.LIGHTNING:
			show()
			texture = lightning
		CombatManager.Elements.ICE:
			show()
			texture = ice
		CombatManager.Elements.FIRE:
			show()
			texture = fire
	return new_elem
