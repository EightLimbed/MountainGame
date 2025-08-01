extends RefCounted

static func generate_mesh(size: int, resolution: int, pos: Vector3) -> Dictionary:
	var noise := FastNoiseLite.new()
	noise.frequency = 0.015
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.fractal_type = FastNoiseLite.FRACTAL_NONE
	noise.seed = 0

	var plane := PlaneMesh.new()
	plane.size = Vector2(size, size)
	plane.subdivide_depth = resolution
	plane.subdivide_width = resolution

	var mesh_arrays := plane.surface_get_arrays(0)
	var vertices: PackedVector3Array = mesh_arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = mesh_arrays[Mesh.ARRAY_NORMAL]
	var tangents: PackedFloat32Array = PackedFloat32Array()
	var indices: PackedInt32Array = mesh_arrays[Mesh.ARRAY_INDEX]
	var uvs: PackedVector2Array = mesh_arrays[Mesh.ARRAY_TEX_UV]

	var get_height = func(x: float, z: float) -> float:
		var p := Vector2(x + pos.x, z + pos.z)
		var normal = noise.get_noise_2dv(p / 2.0) * 12.0
		var large = pow(noise.get_noise_2dv(p / 14.0) * 6.0, 3.0)
		return normal + large - (z + pos.z) / 2.0

	var get_normal = func(x: float, z: float) -> Vector3:
		var eps = float(size) / float(resolution)
		var n = Vector3((get_height.call(x + eps, z) - get_height.call(x - eps, z)) / (2.0 * eps),1.0,(get_height.call(x, z + eps) - get_height.call(x, z - eps)) / (2.0 * eps))
		return n.normalized()

	for i in vertices.size():
		var vx = vertices[i].x
		var vz = vertices[i].z
		var vy = get_height.call(vx, vz)
		vertices[i].y = vy
		vx = vertices[i].x
		vz = vertices[i].z
		var normal = get_normal.call(vx, vz)
		var tangent = normal.cross(Vector3.UP).normalized()
		normals[i] = normal
		tangents.append_array([tangent.x, tangent.y, tangent.z, 1.0])

	return {
		"vertices": vertices,
		"normals": normals,
		"tangents": tangents,
		"indices": indices,
		"uvs": uvs
	}
