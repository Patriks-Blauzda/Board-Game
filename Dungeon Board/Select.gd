extends Sprite

onready var player = get_parent()
onready var tilemap = get_owner().get_node("TileMap")


# Highlights moused over tile, otherwise not visible
func _process(_delta):
	var current_tile = tilemap.world_to_map(get_global_mouse_position())
	
	if tilemap.get_cell(current_tile.x, current_tile.y) != tilemap.INVALID_CELL:
		show()
		global_position = tilemap.map_to_world(current_tile)
	
	else:
		hide()
