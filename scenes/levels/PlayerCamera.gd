extends Camera2D
class_name PlayerCamera

@export var PlayerInfo: PlayerInfoResource
@export_category("Camera Shake")
# How quickly to move through the noise
@export var NOISE_SHAKE_SPEED: float = 30.0
# Noise returns values in the range (-1, 1)
# So this is how much to multiply the returned value by
@export var NOISE_SHAKE_STRENGTH: float = 60.0
# Multiplier for lerping the shake strength to zero
@export var SHAKE_DECAY_RATE: float = 5.0

@onready var rand: RandomNumberGenerator = RandomNumberGenerator.new()
@onready var noise: FastNoiseLite = FastNoiseLite.new()

# Used to keep track of where we are in the noise
# so that we can smoothly move through it
var noise_i: float = 0.0

var shake_strength: float = 0.0

var target_node: Node2D = null
#var player_ref: Player = null ## uses target_node as refernce before target node switches
## above is not needed since youd have to restart anyway

func _ready() -> void:
	position_smoothing_enabled = false
	# Randomize the generated noise
	noise.seed = rand.randi()
	# Period affects how quickly the noise changes values
	noise.frequency = 0.5
	EventBus.camera_shake.connect(apply_noise_shake)
	PlayerInfo.character_died.connect(_on_character_died)


func apply_noise_shake(strength: int) -> void: # 1 for weakest (60), 3 for strongest (180)
	if Settings.camera_shake:
		shake_strength = NOISE_SHAKE_STRENGTH * strength


func _process(delta: float) -> void:
	# Fade out the intensity over time
	shake_strength = lerp(shake_strength, 0.0, SHAKE_DECAY_RATE * delta)
	
	# Shake by adjusting camera.offset so we can move the camera around the level via it's position
	offset = get_noise_offset(delta)
	if is_instance_valid(target_node):
		global_position = target_node.global_position


func get_noise_offset(delta: float) -> Vector2:
	noise_i += delta * NOISE_SHAKE_SPEED
	# Set the x values of each call to 'get_noise_2d' to a different value
	# so that our x and y vectors will be reading from unrelated areas of noise
	return Vector2(
		noise.get_noise_2d(1, noise_i) * shake_strength,
		noise.get_noise_2d(100, noise_i) * shake_strength
	)

func _on_character_died(downed_char: DownedCharacter) -> void:
	if PlayerInfo.team_alive == 0 and downed_char:
		target_node = downed_char
