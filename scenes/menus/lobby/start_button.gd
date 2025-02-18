extends Button

@export_file("*.tscn") var next_scene: String

func _ready() -> void:
	if !multiplayer.is_server():
		queue_free()

func _pressed() -> void:
	if multiplayer.is_server():
		MultiplayerManager._unready_all.rpc()
		MultiplayerManager._switch_to_scene.rpc(next_scene)
