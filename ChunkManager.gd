extends Node3D

@export var chunk_scene : PackedScene
@export var render_distance : int = 7
@export var chunk_size : float = 128.0
@export var chunk_resolution : int = 64
@export var max_threads : int = 8
@onready var player = get_parent().get_node("Player")
var chunk_queue : Array[MeshInstance3D] = []

func _ready() -> void:
	generate_start_chunks()

func generate_start_chunks() -> void:
	for x in range(render_distance):
		for z in range(render_distance):
			create_chunk(Vector2(x,z))

func enqueue(chunk : MeshInstance3D) -> void:
	chunk_queue.append(chunk)

func _process(delta: float) -> void:
	if !chunk_queue.is_empty():
		chunk_queue[0].apply_mesh()
		chunk_queue.pop_front()

func create_chunk(pos : Vector2i) -> void:
	var instance = chunk_scene.instantiate()
	instance.size = chunk_size
	instance.resolution = chunk_resolution
	var x = (pos.x-render_distance/2.0)*chunk_size
	var z = (pos.y-render_distance/2.0)*chunk_size
	instance.position = Vector3(x,0.0,z)
	add_child(instance)
