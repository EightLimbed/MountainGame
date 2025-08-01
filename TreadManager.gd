extends Node3D

var footprints: Array[Vector3] = []

const MAX_TREADS = 96
const TREAD_WIDTH = 16
const TREAD_HEIGHT = 8

var treads_image := Image.create(TREAD_WIDTH, TREAD_HEIGHT, false, Image.FORMAT_RGBF)
var treads_texture := ImageTexture.create_from_image(treads_image)

func _ready() -> void:
	RenderingServer.global_shader_parameter_set("treaded_vertices", treads_texture)
	for i in MAX_TREADS:
		footprints.append(Vector3.ZERO)
	update_tread_texture()

func set_tread(pos : Vector3) -> void:
	footprints[0] = pos

func add_tread(pos: Vector3) -> void:
	footprints.append(pos)
	if footprints.size() > MAX_TREADS:
		footprints.pop_front()

func update_tread_texture() -> void:
	for i in MAX_TREADS:
		var p = footprints[i]
		var x = i % TREAD_WIDTH
		var y = i / TREAD_WIDTH
		treads_image.set_pixel(x, y, Color(p.x, p.y, p.z))
	treads_texture = ImageTexture.create_from_image(treads_image)
	RenderingServer.global_shader_parameter_set("treaded_vertices", treads_texture)
