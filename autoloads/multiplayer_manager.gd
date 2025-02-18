extends Node

#This is for toggling the debug printing
var debug_info: bool = false

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

signal stable_player_data_updated(peer_id, data_key)

var connected: bool = false

const PORT = 1308
const DEFAULT_SERVER_IP = "localhost"
const MAX_CONNECTIONS = 20

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var stream_player_data = {} #This is for things like position that will continiueosly update
var stable_player_data = {} #This is for things that change infrequently like class

#keys are UIDs for the object and then every object should have a "type" as well.
var object_data = {} #This is for objects in the world, this will change frequently

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info = {}

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

################################################
# Managing Connecting
################################################

#Starts a multiplayer peer as the server and connects to it as a player with the servers id (1)
func host_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	if debug_info: print_debug("Server began hosting on port: %s" % str(PORT))

	stable_player_data[1] = player_info
	stream_player_data[1] = {}
	player_connected.emit(1, player_info)
	connected = true

#Attemps to connect to a game on the current address and create a multiplayer peer client
func join_game(ip_adress: String):
	if ip_adress.is_empty():
		ip_adress = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip_adress, PORT)
	if error:
		if debug_info: print_debug("Error joining code is: %s" % str(error))
		return error
	if debug_info: print_debug("Joined as client to server at %s:%s" % [str(ip_adress),str(PORT)])
	multiplayer.multiplayer_peer = peer

#Closes the multiplayer peer
func leave_game():
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()

# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	if debug_info: print_debug("registering player w/ id: %s" % str(new_player_id))
	stable_player_data[new_player_id] = new_player_info
	stream_player_data[new_player_id] = {}
	player_connected.emit(new_player_id, new_player_info)

func _on_connected_ok():
	if debug_info: print_debug("Connected to server")
	var peer_id = multiplayer.get_unique_id()
	stable_player_data[peer_id] = player_info
	stream_player_data[peer_id] = {}
	player_connected.emit(peer_id, player_info)
	connected = true

################################################
# Managing Disconnecting
################################################

func _on_player_disconnected(id):
	if debug_info: print_debug("Player disconnected!")
	if debug_info: print_debug("Removing data for id: %s!" % str(id))
	stable_player_data.erase(id)
	stream_player_data.erase(id)
	player_disconnected.emit(id)

#When failing to connect
func _on_connected_fail():
	if debug_info: print_debug("Connection failed!")
	multiplayer.multiplayer_peer = null

#When the server disconnects
func _on_server_disconnected():
	if debug_info: print_debug("Server dissconnected!")
	connected = false
	multiplayer.multiplayer_peer = null
	stable_player_data.clear()
	stream_player_data.clear()
	server_disconnected.emit()

################################################
# Managing Updating Info
################################################

#Constant update the players position
@rpc("any_peer","unreliable_ordered", "call_local")
func _update_peers_stream(changed_data: Dictionary, player_id: int = -1):
	#If we need an id get the senders id
	if player_id == -1:
		player_id = multiplayer.get_remote_sender_id()
	#Then update each of the data changes
	for entry in changed_data.keys():
		stream_player_data[player_id][entry] = changed_data[entry]

#update the players info that doesn't change very often
@rpc("any_peer","reliable", "call_local")
func _update_peers_stable(changed_data: Dictionary, player_id: int = -1):
	if stable_player_data.size() <= 1:
		for entry in changed_data.keys():
			player_info[entry] = changed_data[entry]
			stable_player_data_updated.emit(player_id, entry)
	else:
		#If we need an id get the senders id
		if player_id == -1:
			player_id = multiplayer.get_remote_sender_id()
		#Then update each of the data changes
		for entry in changed_data.keys():
			stable_player_data[player_id][entry] = changed_data[entry]
			stable_player_data_updated.emit(player_id, entry)

#This will recieve data from the server, such as a new objects location, and will pass off the info via signals to anything that
#might need it, such as an object spawner.
@rpc("any_peer","unreliable","call_local")
func _update_objects_stream(changed_data, object_uid = -1):
	if object_uid == -1:
		object_uid = get_usable_object_uid()
		object_data[object_uid] = {}
		
	#Then update each of the data changes
	for entry in changed_data.keys():
		object_data[object_uid][entry] = changed_data[entry]

func get_usable_object_uid():
	var new_uid = randi()
	if object_data.has(new_uid):
		new_uid = get_usable_object_uid()
	return new_uid

@rpc("authority","reliable","call_local")
func _switch_to_scene(next_scene):
	get_tree().change_scene_to_file(next_scene)

@rpc("authority","reliable","call_local")
func _unready_all():
	_update_peers_stable.rpc({"ready" : false})
