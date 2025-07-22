extends MeshInstance3D

@onready var noise_manager = $"/root/NoiseManager"
var size : int
var resolution : int

func _ready() -> void:
	update_mesh()

func get_normal(x: float, y: float) -> Vector3:
	var epsilon := float(size) / float(resolution)
	var normal := Vector3(
		(noise_manager.get_noise(x + epsilon, y,position) - noise_manager.get_noise(x - epsilon, y,position)) / (2.0 * epsilon),
		1.0,
		(noise_manager.get_noise(x, y + epsilon,position) - noise_manager.get_noise(x, y - epsilon,position)) / (2.0 * epsilon),
	)
	return normal.normalized()

func update_mesh() -> void:
	var plane := PlaneMesh.new()
	plane.subdivide_depth = resolution
	plane.subdivide_width = resolution
	plane.size = Vector2(size, size)
	
	var plane_arrays := plane.get_mesh_arrays()
	var vertex_array: PackedVector3Array = plane_arrays[ArrayMesh.ARRAY_VERTEX]
	var normal_array: PackedVector3Array = plane_arrays[ArrayMesh.ARRAY_NORMAL]
	var tangent_array: PackedFloat32Array = plane_arrays[ArrayMesh.ARRAY_TANGENT]
	
	for i:int in vertex_array.size():
		var vertex := vertex_array[i]
		var normal := Vector3.UP
		var tangent := Vector3.RIGHT
		vertex.y = noise_manager.get_noise(vertex.x, vertex.z,position)
		normal = get_normal(vertex.x, vertex.z)
		tangent = normal.cross(Vector3.UP)
		vertex_array[i] = vertex
		normal_array[i] = normal
		tangent_array[4 * i] = tangent.x
		tangent_array[4 * i + 1] = tangent.y
		tangent_array[4 * i + 2] = tangent.z

	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane_arrays)
	mesh = array_mesh
	var trimesh_collisions = array_mesh.create_trimesh_shape()
	$StaticBody3D/CollisionShape3D.shape = trimesh_collisions
