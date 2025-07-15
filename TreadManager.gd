extends Node3D
var footprints := [Vector3.ZERO]  # Array of Vector3 trampled positions

var treads_image := Image.new()
var treads_texture := ImageTexture.new()

const MAX_TREADS = 128

func add_tread(pos: Vector3):
	footprints.append(pos)
	if footprints.size() > MAX_TREADS:
		footprints.pop_front()
	update_tread_texture()

func update_tread_texture():
	if footprints.is_empty():
		return

	var count = min(footprints.size(), MAX_TREADS)

	var image := Image.create(MAX_TREADS, 1, false, Image.FORMAT_RGBF)

	for i in MAX_TREADS:
		if i < count:
			var p = footprints[i]
			image.set_pixel(i, 0, Color(p.x, p.y, p.z))
		else:
			image.set_pixel(i, 0, Color(-1000.0, -1000.0, -1000.0)) # filler

	treads_texture = ImageTexture.create_from_image(image)

	#upload uniforms
	RenderingServer.global_shader_parameter_set("treaded_vertices", treads_texture)
	RenderingServer.global_shader_parameter_set("total_treads", count)
