extends Button

func _pressed() -> void:
	OptionsManager.options["Name"] = $"../TextEdit".text
	OptionsManager._options_updated()
