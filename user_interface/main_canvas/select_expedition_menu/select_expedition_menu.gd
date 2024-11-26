extends Control
class_name SelectExpeditionMenu

## FUTURE: Make this more easily expandable (then again doing this manually is very simple)

@onready var details_tutorial: ExpeditionDetails = %Details_Tutorial
@onready var details_blue_city: ExpeditionDetails = %Details_BlueCity

func _ready() -> void:
	_on_novice_pressed()

func _on_novice_pressed() -> void:
	details_tutorial.show()
	details_blue_city.hide()


func _on_blue_city_pressed() -> void:
	details_tutorial.hide()
	details_blue_city.show()
