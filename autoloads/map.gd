extends Node

#This is the map of cells
#It looks like this:
#{ CellA: {Side1: CellB, Side2: CellC}}
#CellA being the actual cell
#Then if a side is in the sub dict then that means a path goes from that side to the value cell
var map: Dictionary = {}
var cell_positions: Dictionary = {} #This is used for easily finding the cell at a position, mostly for map generation

#var player_pos: int = -1

@rpc("authority","reliable","call_local")
func set_cleint_map(new_map: Dictionary):
	_set_map(new_map)

func _set_map(new_map: Dictionary):
	map = new_map
	pick_player_start()

func _generate_map(map_size: int):
	map.clear()
	
	#Create cells with no paths and a position and type
	for x in range(map_size):
		for y in range(map_size):
			#Skip the occasional cell to add variety
			if randf() < 0.30:
				continue
			
			#Create the cell
			var new_cell_id: int = get_new_cell_id()
			map[new_cell_id] = {}
			
			#Get a type for the cell
			var new_cell_type: String = ""
			if randf() < 1.60: new_cell_type = cell_types.pick_random() #This is set to a 160 percent chance cause I don't have any types that do anything yet
			else: new_cell_type = "Neutral"
			
			#get the cells position for path building
			var new_cell_position: Vector2i = Vector2i(x, y)
			cell_positions[new_cell_position] = new_cell_id
			
			#Assign the value to the map storage
			map[new_cell_id]["type"] = new_cell_type
			map[new_cell_id]["position"] = new_cell_position
			map[new_cell_id]["coin"] = true #all spots start with a coin
	
	#Path Builder
	for cell: int in map:
		#Cardinal Directions
		if randf() < 0.30: connect_cell_north(cell)
		if randf() < 0.30: connect_cell_south(cell, map_size)
		if randf() < 0.30: connect_cell_west(cell)
		if randf() < 0.30: connect_cell_east(cell, map_size)
		
		#InterCardinalDirections
		if randf() < 0.30: connect_cell_northeast(cell, map_size)
		if randf() < 0.30: connect_cell_southwest(cell, map_size)
		if randf() < 0.30: connect_cell_northwest(cell)
		if randf() < 0.30: connect_cell_southeast(cell, map_size)

	#Get rid of unconnected cells
	#This only gets rid of singular fully disconnected cells and not seperate groups
	for cell: int in map:
		if map[cell].size() == 0:
			map.erase(cell)
	
	checked_cells = []
	connect_disconnects()

func connect_disconnects():
	get_cell_patch(map.keys().pick_random())
	
	for cell in map.keys():
		if !checked_cells.has(cell):
			var cell_in_map = checked_cells.pick_random()
			map[cell][find_unconnected_dir(cell)[0]] = cell_in_map
			map[cell_in_map][find_unconnected_dir(cell_in_map)[0]] = cell
			connect_disconnects()
			return

func find_unconnected_dir(cell):
	var open_dirs = ["North","East","South","West","NorthEast","SouthEast","SouthWest","NorthWest"]
	for dir in map[cell]:
		open_dirs.erase(dir)
	return open_dirs

var checked_cells: Array = []
var done_checking: bool = false

func get_cell_patch(cell):
	checked_cells.append(cell)
	for connected_dir in map[cell]:
		if !sides.has(connected_dir): continue
		if !checked_cells.has(map[cell][connected_dir]):
			get_cell_patch(map[cell][connected_dir])
	
#This is a function for if I wanna make it choose a good start and not a random one
func pick_player_start():
	MultiplayerManager._update_peers_stable.rpc({"position": map.keys().pick_random()})
	MultiplayerManager._update_peers_stable.rpc({"coins": 1})
	_update_cell.rpc(MultiplayerManager.stable_player_data[multiplayer.get_unique_id()]["position"], {"coin": false})

#CARDINAL DIRECTION CONNECTIONS
func connect_cell_north(cell: int):
	if map[cell]["position"].y <= 0:
		return
	for y in range(map[cell]["position"].y-1,-1,-1):
		if cell_positions.has(Vector2i(map[cell]["position"].x, y)):
			map[cell]["North"] = cell_positions[Vector2i(map[cell]["position"].x, y)]
			map[cell_positions[Vector2i(map[cell]["position"].x, y)]]["South"] = cell
			return

func connect_cell_south(cell: int, map_size: int):
	if map[cell]["position"].y >= map_size:
		return
	for y in range(map[cell]["position"].y+1, map_size):
		if cell_positions.has(Vector2i(map[cell]["position"].x, y)):
			map[cell]["South"] = cell_positions[Vector2i(map[cell]["position"].x, y)]
			map[cell_positions[Vector2i(map[cell]["position"].x, y)]]["North"] = cell
			return

func connect_cell_west(cell: int):
	if map[cell]["position"].x <= 0:
		return
	for x in range(map[cell]["position"].x-1,-1,-1):
		if cell_positions.has(Vector2i(x, map[cell]["position"].y)):
			map[cell]["West"] = cell_positions[Vector2i(x, map[cell]["position"].y)]
			map[cell_positions[Vector2i(x, map[cell]["position"].y)]]["East"] = cell
			return

func connect_cell_east(cell: int, map_size: int):
	if map[cell]["position"].x >= map_size:
		return
	for x in range(map[cell]["position"].x+1, map_size):
		if cell_positions.has(Vector2i(x, map[cell]["position"].y)):
			map[cell]["East"] = cell_positions[Vector2i(x, map[cell]["position"].y)]
			map[cell_positions[Vector2i(x, map[cell]["position"].y)]]["West"] = cell
			return

#InterCardinalDirections
func connect_cell_northeast(cell: int, map_size: int):
	if map[cell]["position"].y <= 0 or map[cell]["position"].x >= map_size:
		return
	for y in range(map[cell]["position"].y-1,-1,-1):
		for x in range(map[cell]["position"].x+1, map_size):
			if cell_positions.has(Vector2i(x, y)):
				map[cell]["Northeast"] = cell_positions[Vector2i(x, y)]
				map[cell_positions[Vector2i(x, y)]]["Southwest"] = cell
				return

func connect_cell_southwest(cell: int, map_size: int):
	if map[cell]["position"].y >= map_size or map[cell]["position"].x <= 0:
		return
	for y in range(map[cell]["position"].y+1, map_size):
		for x in range(map[cell]["position"].x-1,-1,-1):
			if cell_positions.has(Vector2i(x, y)):
				map[cell]["Southwest"] = cell_positions[Vector2i(x, y)]
				map[cell_positions[Vector2i(x, y)]]["Northeast"] = cell
				return

func connect_cell_northwest(cell: int):
	if map[cell]["position"].y <= 0 or map[cell]["position"].x <= 0:
		return
	for y in range(map[cell]["position"].y-1,-1,-1):
		for x in range(map[cell]["position"].x-1,-1,-1):
			if cell_positions.has(Vector2i(x, y)):
				map[cell]["Northwest"] = cell_positions[Vector2i(x, y)]
				map[cell_positions[Vector2i(x, y)]]["Southeast"] = cell
				return

func connect_cell_southeast(cell: int, map_size: int):
	if map[cell]["position"].y >= map_size or map[cell]["position"].x >= map_size:
		return
	for y in range(map[cell]["position"].y+1, map_size):
		for x in range(map[cell]["position"].x+1, map_size):
			if cell_positions.has(Vector2i(x, y)):
				map[cell]["Southeast"] = cell_positions[Vector2i(x, y)]
				map[cell_positions[Vector2i(x, y)]]["Northwest"] = cell
				return

func get_new_cell_id():
	var new_id: int = randi()
	if map.has(new_id):
		return get_new_cell_id()
	return new_id

func move_player(move_dir: String):
	var player_pos = MultiplayerManager.stable_player_data[multiplayer.get_unique_id()]["position"]
	#Can't move if not on a map
	if player_pos == null:
		return false
	if map[player_pos].has(move_dir):
		MultiplayerManager._update_peers_stable.rpc({"position": map[player_pos][move_dir]})
		if map[map[player_pos][move_dir]]["coin"] == true:
			#Adds a coin to the player
			MultiplayerManager._update_peers_stable.rpc({"coins": MultiplayerManager.stable_player_data[multiplayer.get_unique_id()]["coins"] + 1})
			_update_cell.rpc(map[player_pos][move_dir], {"coin": false})
		return true
	return false

@rpc("any_peer","reliable", "call_local")
func _update_cell(cell_id: int, changed_data: Dictionary):
	#Then update each of the data changes
	for entry in changed_data.keys():
		map[cell_id][entry] = changed_data[entry]

var cell_types: Array = [
	"Neutral", 
	"Red", 
	"Blue",
	"Yellow"
]

var sides: Array = [
	"North",
	"Northeast",
	"East",
	"Southeast",
	"South",
	"Southwest",
	"West",
	"Northwest"
]
