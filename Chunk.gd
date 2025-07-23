extends MeshInstance3D

var size: int
var resolution: int
var thread := Thread.new()
@export var generator_script : Script
var pos : Vector3

func _ready():
	pos = position
	thread.start(_threaded_generate)

func _threaded_generate():
	var generator = generator_script.new()
	var mesh_data = generator.generate_mesh(size, resolution, pos)
	call_deferred("apply_mesh", mesh_data)

func apply_mesh(data: Dictionary) -> void:
	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = data["vertices"]
	arrays[ArrayMesh.ARRAY_NORMAL] = data["normals"]
	arrays[ArrayMesh.ARRAY_TANGENT] = data["tangents"]
	arrays[ArrayMesh.ARRAY_INDEX] = data["indices"]
	arrays[ArrayMesh.ARRAY_TEX_UV] = data["uvs"]
	
	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var shape = array_mesh.create_trimesh_shape()
	$StaticBody3D/CollisionShape3D.shape = shape
	mesh = array_mesh
