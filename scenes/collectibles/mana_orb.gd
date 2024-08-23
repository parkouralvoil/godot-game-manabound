extends Sprite2D
class_name ManaOrb

const texture_small: Texture = preload("res://resources/textures/mana_orb/mana_orb_small.tres")
const texture_medium: Texture = preload("res://resources/textures/mana_orb/mana_orb_medium.tres")

@export var inventory: PlayerInventory
@export var sfx_collected: AudioStream

enum possible_tiers
{
	SMALL,
	MEDIUM,
}

var tier: possible_tiers = possible_tiers.SMALL

var value: int = 5
var speed: float = 600
var go_towards_player: bool = false

@onready var current_trail: Trail = $ManaTrail

func _ready() -> void:
	current_trail.hide()
	EnemyAiManager.call_attract_orbs.connect(attract_orb)
	match tier:
		possible_tiers.SMALL:
			texture = texture_small
			current_trail.width = 5
			value = 5
		possible_tiers.MEDIUM:
			texture = texture_medium
			current_trail.width = 10
			value = 20


func _physics_process(delta: float) -> void:
	if go_towards_player:
		var dir: float = get_angle_to(EnemyAiManager.player_position)
		position += speed * Vector2.RIGHT.rotated(dir) * delta
		if (EnemyAiManager.player_position - global_position).length_squared() < 40:
			collected()


func attract_orb() -> void:
	current_trail.show()
	go_towards_player = true


func collected() -> void:
	inventory.mana_orbs += value
	
	if SoundPlayer.collected_mana_cooldown(): # return true if the CD is done. False otherwise
		SoundPlayer.play_sound(sfx_collected, -20, 0.88)
	queue_free()
