extends CharacterBody2D ## needs to extend from interactable class
class_name DownedCharacter

#@export var PlayerInfo: PlayerInfoResource ## to allow the camera to follow this downed char
## no need, character scene will manage this instead

## set by character.tscn when this is instantiated
var linked_character: Character 
var texture: Texture

## movement (when falling)
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var air_deaccel: float = 200
var x_direction: int = 1

## specific logic variables
var falling: bool = true
var can_revive: bool = true
var interacting: bool = false

## revive properties:
var revive_speed: float = 80
var revive_progress: float = 0:
	set(val):
		revive_progress = val
		progress_bar.value = val
var max_revive: float = 100

@onready var sprite: Sprite2D = $Sprite2D
@onready var tip: Label = $Tip
@onready var progress_bar: ProgressBar = $ReviveBarProgress

## components:
@onready var interactable: Interactable = $Interactable

"""
*ONLY CURRENT CHAR CAN DIE, OFF FIELD CHARS CANNOT DIE
- so only projectiles should kill, debuffs like poison can only bring char down to 1 HP
when char dies,
- hide current char
- 1 second camera frozen in air
- downed_char spawns then falls down to floor
- swap to next available char
	- if no available char, gameover, return to main scene
"""

func _ready() -> void:
	interactable.set_color(self)
	if texture:
		sprite.texture = texture
	velocity = Vector2(200 * -x_direction, -100)
	sprite.scale.y = -x_direction
	tip.hide()
	progress_bar.hide()
	can_revive = false
	EventBus.interactable_detected.connect(toggle_info)
	EventBus.level_cleared.connect(revive_char.unbind(1)) ## to revive everyone immediately
	EventBus.exit_door_interacted.connect(revive_char) ## if im skipping_lvl thru console
	EventBus.returned_to_mainhub.connect(queue_free)


func try_interact() -> void: ## called by interactable
	if can_revive and not interacting:
		interacting = true
		EventBus.interactable_held.emit()


func try_release() -> void:
	if interacting:
		interacting = false
		EventBus.interactable_finished.emit()


func _process(delta: float) -> void: ## I NEED DELTA so dont chagne to input function
	if interacting:
		revive_progress = clampf(revive_progress + revive_speed * delta,
				0,
				max_revive)
		if revive_progress >= max_revive:
			EventBus.interactable_finished.emit()
			revive_char() ## HAS QUEUE FREE
	else:
		revive_progress = 0


func _physics_process(delta: float) -> void:
	move_and_slide()
	if not is_on_floor():
		velocity.y = min(velocity.y + gravity * delta, gravity/1.25)
		_horizontal_deaccel(delta)
		falling = true
	else:
		velocity = Vector2.ZERO
		falling = false


func _horizontal_deaccel(_delta: float) -> void:
	if velocity.x >= 0:
		velocity.x = max(velocity.x - air_deaccel * 1 * _delta, 0)
	if velocity.x < 0:
		velocity.x = min(velocity.x - air_deaccel * -1 * _delta, 0)


func revive_char() -> void:
	linked_character.revive()
	queue_free()


func toggle_info(event_bus_interactable: Interactable) -> void:
	if not event_bus_interactable or falling: ## is null check necessary?
		tip.hide()
		progress_bar.hide()
		can_revive = false
	elif event_bus_interactable == interactable:
		tip.show()
		progress_bar.show()
		can_revive = true
	else:
		tip.hide()
		progress_bar.hide()
		can_revive = false
