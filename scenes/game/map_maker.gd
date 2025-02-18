extends Node

@export var map_size: int = 5

func _ready() -> void:
	if multiplayer.is_server():
		Map._generate_map(map_size)
		Map.set_cleint_map.rpc(Map.map)
