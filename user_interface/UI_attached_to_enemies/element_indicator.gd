extends TextureRect
class_name ElementIndicator

@export var lightning: AtlasTexture
@export var ice: AtlasTexture
@export var fire: AtlasTexture

var element: CombatManager.Elements = CombatManager.Elements.NONE :
	set(value):
		element = _on_elem_change(value)

func _ready() -> void:
	element = CombatManager.Elements.NONE ## might have to change this

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
