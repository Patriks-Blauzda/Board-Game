extends TileMap

var path = PoolVector2Array()


# Checks all 4 directions for tiles, adds them to next_tiles array and returns the array
# Array is used in _get_path()
# Also checks if tile already exists in path array
func _get_next_tiles(previous : Vector2, current : Vector2):
	var next_tiles = []
	
	# Iterates through the 4 directions, checking for the tile moved from and if the space is empty
	for dir in Global.directions:
		if current - dir != previous && get_cellv(current - dir) != INVALID_CELL:
			if !path.has(current - dir):
				next_tiles.append(current - dir)
	
	
	return next_tiles


# Generates path starting from Vector2(0, 0), which should always be the starting point
func _get_path(previous : Vector2 = Vector2(0, 0), current : Vector2 = Vector2(0, 0)):
	path.append(current)
	
	
	var next_tiles = []
	
	# Repeats until the end is found or more than one direction is found
	while(get_cellv(path[path.size() - 1]) != 2 || next_tiles.size() > 1):
		next_tiles = _get_next_tiles(previous, current)
		
		# If there are multiple pats, runs itself for each direction
		if next_tiles.size() > 1:
			for i in next_tiles:
				_get_path(current, i)
		
		# Simply adds tile to path if only one direction to move in
		elif !next_tiles.empty():
			path.append(next_tiles[0])
		
		# Ends the loop if something goes wrong
		else:
			break
		
		previous = current
		current = next_tiles[0]


func _ready():
	_get_path()
