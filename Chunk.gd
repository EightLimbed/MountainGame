extends MeshInstance3D

@export var size: int
@export var resolution: int
@export var generator_script: Script

@onready var parent = get_parent()
var pos: Vector3
var generator
var active_thread : Thread
var generating := false
var data : Dictionary

func _ready() -> void:
	generator = generator_script.new()
	start_generate()

func _process(_delta: float) -> void:
	# check when not generating a chunk currently
	if generating:
		return

	var dist = float(parent.render_distance) / 2.0
	var player_chunk_pos = parent.player.position / size
	var chunk_pos = floor(position / size)
	var dif = player_chunk_pos - chunk_pos - Vector3(0.5,0.0,0.5)

	var moved := false

	if dif.x > dist:
		position.x += parent.render_distance * size
		moved = true
	elif dif.x < -dist:
		position.x -= parent.render_distance * size
		moved = true

	if dif.z > dist:
		position.z += parent.render_distance * size
		moved = true
	elif dif.z < -dist:
		position.z -= parent.render_distance * size
		moved = true

	if moved:
		start_generate()

func start_generate() -> void:
	#wait for previous thread to finish (needs to be cleaned up)
	if active_thread and active_thread.is_alive():
		active_thread.wait_to_finish()

	generating = true
	pos = position
	active_thread = Thread.new()
	active_thread.start(Callable(self, "_threaded_generate"))

func _threaded_generate() -> void:
	var mesh_data: Dictionary = generator.generate_mesh(size, resolution, pos)
	call_deferred("enqueue_mesh", mesh_data)

func enqueue_mesh(mesh_data):
	parent.enqueue(self)
	data = mesh_data

func apply_mesh() -> void:
	# use mesh arrays
	var arrays := []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = data["vertices"]
	arrays[ArrayMesh.ARRAY_NORMAL] = data["normals"]
	arrays[ArrayMesh.ARRAY_TANGENT] = data["tangents"]
	arrays[ArrayMesh.ARRAY_INDEX] = data["indices"]
	arrays[ArrayMesh.ARRAY_TEX_UV] = data["uvs"]

	# apply mesh+collisions
	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh = array_mesh

	var shape := array_mesh.create_trimesh_shape()
	$StaticBody3D/CollisionShape3D.shape = shape

	# cleanup
	generating = false
	if active_thread:
		active_thread.wait_to_finish()
		active_thread = null
