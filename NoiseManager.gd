extends Node

@onready var noise := FastNoiseLite.new()
@onready var random := RandomNumberGenerator.new()

func _ready() -> void:
	noise.frequency = 0.015
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.fractal_type = FastNoiseLite.FRACTAL_NONE
	noise.seed = random.randi()

func get_noise(x: float, z: float, pos : Vector3) -> float:
	var updated_pos : Vector2 = Vector2(x+pos.x,z+pos.z)
	var normal = noise.get_noise_2dv(updated_pos)*6.0
	var large = (noise.get_noise_2dv(updated_pos/128.0)*6.0)**3
	return normal+large-(z+pos.z)/3.0
