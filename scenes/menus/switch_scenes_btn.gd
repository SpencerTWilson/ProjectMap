extends Button

@export_file("*.tscn") var next_scene: String

func _pressed() -> void:
	get_tree().change_scene_to_file(next_scene)
	MultiplayerManager.leave_game()
