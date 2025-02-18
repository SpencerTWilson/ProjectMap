extends HBoxContainer

@export var displays: Array[Node] = []

func _ready() -> void:
	MultiplayerManager.player_connected.connect(_player_connect)
	MultiplayerManager.player_disconnected.connect(_player_disconnect)
	MultiplayerManager.stable_player_data_updated.connect(_data_update)
	_display_names()

func _data_update(_id, key):
	if key == "theme" or key == "name":
		_display_names()

func _player_disconnect(_id):
	_display_names()

func _player_connect(_id, _info):
	_display_names()

func _display_names():
	var i = 0
	for player in MultiplayerManager.stable_player_data:
		if MultiplayerManager.stable_player_data[player].has("name"):
			displays[i].text = MultiplayerManager.stable_player_data[player]["name"]
			#var player_theme = MultiplayerManager.stable_player_data[player]["theme"]
			#displays[i].modulate = OptionsManager.themes[player_theme]["Main Color"]
			
		i += 1
		
	var num_players = MultiplayerManager.stable_player_data.size()
	for j in range(9):
		displays[j].visible = num_players > j
