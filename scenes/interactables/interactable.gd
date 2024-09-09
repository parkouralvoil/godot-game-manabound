extends Area2D
class_name Interactable

signal changed_show(allowed: bool)

## no longer needed
#var can_be_interacted: bool = true ## set by parent (if this is used as a composition)
#var being_interacted: bool = false ## set to true when player is holding F

## NOTE: should interactable component
## have control nodes? nah id rather have them be children of parent

func select_this() -> void:
	EventBus.interactable_detected.emit(self)
