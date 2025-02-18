extends Button

@export_file("*.tscn") var lobby_file: String

func _pressed() -> void:
	MultiplayerManager.host_game()
	get_tree().change_scene_to_file(lobby_file)
