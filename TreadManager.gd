extends Node3D
var footprints : Array[Vector3] = []  # Array of Vector3 trampled positions

var treads_image := Image.new()
var treads_texture := ImageTexture.new()

const MAX_TREADS = 128

func _ready() -> void:
	RenderingServer.global_shader_parameter_set("treaded_vertices", treads_texture)
	for i in MAX_TREADS:
		footprints.append(Vector3.ZERO)

func add_tread(pos: Vector3):
	footprints.append(pos)
	if footprints.size() > MAX_TREADS:
		footprints.pop_front()
	update_tread_texture()

func update_tread_texture():
	var image := Image.create(MAX_TREADS, 1, false, Image.FORMAT_RGBF)
	for i in MAX_TREADS:
		var p = footprints[i]
		image.set_pixel(i, 0, Color(p.x, p.y, p.z))
	treads_texture = ImageTexture.create_from_image(image)
	#upload uniforms
	RenderingServer.global_shader_parameter_set("treaded_vertices", treads_texture)
