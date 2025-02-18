extends Button

var settings = preload("res://scenes/menus/settings/settings.tscn")

func _pressed() -> void:
		get_tree().current_scene.add_child(settings.instantiate())
