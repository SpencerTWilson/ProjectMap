extends Button

@export_file("*.tscn") var lobby_file: String

func _pressed() -> void:
	MultiplayerManager.join_game($"../IPTextEdit".text)
	get_tree().change_scene_to_file(lobby_file)
