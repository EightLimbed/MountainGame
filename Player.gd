extends RigidBody3D

#camera
@onready var camera := $Camera3D
var pitch : float = 1.0
var yaw : float = 0.0
var sensitivity = 0.002
var camera_distance := 8.0
var camera_height := 2.0

#movement
var airborne : int = 0
const SPEED = 5000.0

#treads
@onready var tread_manager = $"/root/TreadManager"
var old_tread_pos : Vector3

func _ready():
	old_tread_pos = position

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
	#camera zoom
	if Input.is_action_just_pressed("ZoomIn"):
		camera_distance /= 1.1
	elif Input.is_action_just_pressed("ZoomOut"):
		camera_distance *= 1.1
	#just for camera direction and stuff
	var offset := Vector3(0, camera_height, camera_distance)
	offset = Basis(Vector3(1, 0, 0), pitch) * offset  # apply pitch
	offset = Basis(Vector3(0, 1, 0), yaw) * offset    # apply yaw
	camera.global_position = global_position + offset
	camera.look_at(global_position + Vector3(0, camera_height, 0), Vector3.UP)

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	var forward = Vector3(sin(yaw), 0, cos(yaw)).normalized()
	var right = Vector3(forward.z, 0, -forward.x).normalized()
	deal_with_footprints()
	if input_dir != Vector2.ZERO:
		if airborne == 0:
			var rot_dir := (right * input_dir.y + -forward * input_dir.x).normalized()
			apply_torque(rot_dir*SPEED*delta*4.0)
		var move_dir := (right * input_dir.x + forward * input_dir.y).normalized()
		apply_central_force(move_dir * SPEED * delta)

func deal_with_footprints():
	if airborne > 0:
		tread_manager.set_tread(position)
		if (old_tread_pos- position).length() > 2.0:
			tread_manager.add_tread(position)
			old_tread_pos = position
		tread_manager.update_tread_texture()

func _on_ground_detector_body_entered(_body: Node3D) -> void:
	airborne += 1

func _on_air_detector_body_exited(_body: Node3D) -> void:
	airborne -= 1
