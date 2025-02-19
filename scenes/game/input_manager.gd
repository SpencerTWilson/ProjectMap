extends Node

@export var text_out: TextOutput

func _new_map():
	var player_pos = MultiplayerManager.stable_player_data[multiplayer.get_unique_id()]["position"]
	var dir_string: String = ""
	for side in Map.map[Map.player_pos]:
		dir_string += side
		dir_string += ", "
	text_out._print_text("[color=Slategray]You started on a[/color] %s [color=Slategray]space.\nYou can move in dir(s)[/color] %s" % [Map.map[player_pos]["type"], dir_string])

#Input Handeling > MOVE TO ANOTHER SCRIPT NOT AN AUTOLOAD!
func _input(event: InputEvent) -> void:
	var move_dir: String = ""
	
	if event.is_action_pressed("move_up"):
		move_dir = "North"
	elif event.is_action_pressed("move_up_right"):
		move_dir = "Northeast"
	elif event.is_action_pressed("move_right"):
		move_dir = "East"
	elif event.is_action_pressed("move_down_right"):
		move_dir = "Southeast"
	elif event.is_action_pressed("move_down"):
		move_dir = "South"
	elif event.is_action_pressed("move_down_left"):
		move_dir = "Southwest"
	elif event.is_action_pressed("move_left"):
		move_dir = "West"
	elif event.is_action_pressed("move_up_left"):
		move_dir = "Northwest"

	#if we aren't moving then we don't need to do anything here
	if move_dir == "":
		return
	
	if Map.move_player(move_dir):
		MultiplayerManager._update_peers_stable.rpc({"entered_dir": move_dir})
		var player_pos = MultiplayerManager.stable_player_data[multiplayer.get_unique_id()]["position"]
		var dir_string: String = ""
		for side in Map.map[player_pos]:
			if Map.directions.has(side):
				dir_string += side
				dir_string += ", "
		text_out._print_text("[color=Slategray]You moved [/color]%s[color=Slategray] to a[/color] %s[color=Slategray] space.\nYou can move in dir(s)[/color] %s" % [move_dir, Map.map[player_pos]["type"], dir_string])
		shout_movement.rpc(move_dir, Map.map[player_pos]["type"])
		
@rpc("any_peer","reliable","call_remote")
func shout_movement(move_dir,cell_type):
	var player_name = MultiplayerManager.stable_player_data[multiplayer.get_remote_sender_id()]["name"]
	text_out._print_text("%s [color=Slategray]moved [/color]%s[color=Slategray] to a[/color] %s[color=Slategray] space.[/color]" % [player_name, move_dir, cell_type])
