extends RigidBody3D

var camera_zoom : float = 4.0
var pitch : float = 1.0
var yaw : float = 0.0
var sensitivity = 0.002
var camera_distance := 6.0
var camera_height := 2.0
var airborne : bool = false
const SPEED = 1000.0
@onready var camera := $Camera3D

func _ready():
	sleeping = false

func _unhandled_input(event: InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			yaw -= event.relative.x * sensitivity
			pitch = clamp(pitch - event.relative.y * sensitivity, -PI / 3, PI / 3)
		if event.is_action_pressed("ui_cancel"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta: float) -> void:
	#just for camera direction and stuff
	var offset := Vector3(0, camera_height, camera_distance)
	offset = Basis(Vector3(1, 0, 0), pitch) * offset  # Apply pitch
	offset = Basis(Vector3(0, 1, 0), yaw) * offset    # Apply yaw
	camera.global_position = global_position + offset
	camera.look_at(global_position + Vector3(0, camera_height, 0), Vector3.UP)

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	var forward = Vector3(sin(yaw), 0, cos(yaw)).normalized()
	var right = Vector3(forward.z, 0, -forward.x).normalized()
	var move_dir := (right * input_dir.x + forward * input_dir.y).normalized()
	if move_dir != Vector3.ZERO:
		apply_central_force(move_dir * SPEED * delta)

func _on_ground_detector_body_entered(_body: Node3D) -> void:
	airborne = false

func _on_air_detector_body_exited(_body: Node3D) -> void:
	airborne = true
