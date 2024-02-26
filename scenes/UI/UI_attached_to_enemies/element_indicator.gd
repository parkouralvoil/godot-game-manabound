extends Sprite2D

@export var lightning: AtlasTexture
@export var ice: AtlasTexture

@onready var HC: EnemyHealthComponent = get_parent()

var element: CombatManager.Elements = CombatManager.Elements.NONE :
	set(value):
		element = _on_elem_change(value)
	get:
		return element

func _ready() -> void:
	assert(HC, "not there")
	element = HC.element_initial

func _on_elem_change(new_elem: CombatManager.Elements) -> CombatManager.Elements:
	#print(CombatManager.Elements.keys()[new_elem])
	match new_elem:
		CombatManager.Elements.NONE:
			set_deferred("visible", false)
		CombatManager.Elements.LIGHTNING:
			set_deferred("visible", true)
			texture = lightning
		CombatManager.Elements.ICE:
			set_deferred("visible", true)
			texture = ice
	return new_elem
