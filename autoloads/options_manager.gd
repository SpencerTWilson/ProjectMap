extends Node

signal options_updated()

var options: Dictionary = {}
var options_file: String = "res://autoloads/options.json"

#Create the options screen, pause the game
func _open_options_menu():
	pass

#Should grab the saved options
func _ready():
	var options_json_string: String = FileAccess.get_file_as_string(options_file)
	options = JSON.parse_string(options_json_string)
	#just because we technically changed the options
	_options_updated()

func _options_updated():
	var file = FileAccess.open(options_file, FileAccess.WRITE)
	file.store_string(JSON.stringify(options))
	file.close()
	MultiplayerManager._update_peers_stable.rpc({"name": options["Name"]})
	options_updated.emit()
