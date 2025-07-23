extends Node3D

@export var chunk : PackedScene
@export var render_distance : int = 3
@export var chunk_size : int = 256
@export var chunk_resolution : int = chunk_size
@export var max_threads : int = 8

func _ready() -> void:
	generate_start_chunks()

func generate_start_chunks() -> void:
	for x in range(render_distance):
		for z in range(render_distance):
			create_chunk(Vector2(x,z))

func create_chunk(pos : Vector2) -> void:
	var instance = chunk.instantiate()
	instance.size = chunk_size
	instance.resolution = chunk_resolution
	var x = (pos.x-render_distance/2)*chunk_size
	var z = (pos.y-render_distance/2)*chunk_size
	instance.position = Vector3(x,0.0,z)
	add_child(instance)
