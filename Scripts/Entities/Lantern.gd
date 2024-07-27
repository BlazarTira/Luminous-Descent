extends PointLight2D

@export var min_energy = 4.0
@export var max_energy = 6.0
@export var flicker_speed = 5.0

var flicker_timer = 0.0
var noise = FastNoiseLite.new()

func _ready():
	randomize()  # Ensure randomness each time the game runs
	noise.seed = randi()  # Set a random seed for the noise
	noise.set_noise_type(FastNoiseLite.TYPE_SIMPLEX_SMOOTH)
	noise.frequency = 1.0

func _process(delta):
	# Increment the flicker timer
	flicker_timer += delta * flicker_speed

	# Calculate a new energy level based on a noise function
	var noise_value = noise.get_noise_1d(flicker_timer)
	var noise_energy = lerp(min_energy, max_energy, (noise_value + 1) / 2)  # Normalize noise_value to [0, 1]

	# Apply the new energy level to the light
	energy = noise_energy
