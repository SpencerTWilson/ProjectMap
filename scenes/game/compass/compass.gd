extends Control

var player_id: int = 1

func _ready() -> void:
	player_id = multiplayer.get_unique_id()
	MultiplayerManager.stable_player_data_updated.connect(_update_compass)
	_update_compass(player_id, "position")
	
func _update_compass(peer_id: int, data_key: String):
	if peer_id != player_id:
		return
	
	match data_key:
		"position":
			if MultiplayerManager.stable_player_data[player_id].has("position"):
				_update_color(MultiplayerManager.stable_player_data[player_id]["position"])
				_update_exit_arrows(MultiplayerManager.stable_player_data[player_id]["position"])
		"enter_dir":
			_update_enter_dir()
		_:
			return

func _update_color(cell_id: int):
	var cell_type: String = Map.map[cell_id]["type"]
	if cell_type_colors.has(cell_type): $Cell.modulate = cell_type_colors[cell_type]

func _update_exit_arrows(cell_id: int):
	for dir in Map.directions:
		if Map.map[cell_id].has(dir):
			get_dir_arrow(dir).visible = true
		else:
			get_dir_arrow(dir).visible = false

func _update_enter_dir():
	for dir in Map.directions:
		get_dir_arrow(dir, false).visible = false
	get_dir_arrow(MultiplayerManager.stable_player_data[player_id]["enter_dir"], false).visible = true

func get_dir_arrow(dir: String, exit: bool = true):
	match dir:
		"North":
			if !exit: return $Entrances/North
			return $Exits/North
		"East":
			if !exit: return $Entrances/East
			return $Exits/East
		"South":
			if !exit: return $Entrances/South
			return $Exits/South
		"West":
			if !exit: return $Entrances/West
			return $Exits/West
		"Northeast":
			if !exit: return $Entrances/Northeast
			return $Exits/Northeast
		"Southeast":
			if !exit: return $Entrances/Southeast
			return $Exits/Southeast
		"Southwest":
			if !exit: return $Entrances/Southwest
			return $Exits/Southwest
		"Northwest":
			if !exit: return $Entrances/Northwest
			return $Exits/Northwest

#CellType: Color
var cell_type_colors: Dictionary = {
	"Neutral": Color.GAINSBORO,
	"Yellow": Color.GOLD,
	"Red": Color.FIREBRICK,
	"Blue": Color.DODGER_BLUE
}
