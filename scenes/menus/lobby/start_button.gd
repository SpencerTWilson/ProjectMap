extends Button

@export_file("*.tscn") var next_scene: String

func _ready() -> void:
	if !multiplayer.is_server():
		queue_free()
	
	disabled = true
	MultiplayerManager.player_connected.connect(_check_if_can_start)
	MultiplayerManager.player_disconnected.connect(_check_if_can_start)

func _check_if_can_start(_player_id: int = 0, _player_info: Dictionary = {}) -> void:
	disabled = MultiplayerManager.stable_player_data.size() < 2

func _pressed() -> void:
	if multiplayer.is_server():
		MultiplayerManager._unready_all.rpc()
		MultiplayerManager._switch_to_scene.rpc(next_scene)
