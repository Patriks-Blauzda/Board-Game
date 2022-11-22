extends Sprite


onready var tilemap = get_parent().get_node("TileMap")


# Highlights moused over tile, otherwise not visible
func _process(delta):
	var current_tile = tilemap.world_to_map(get_global_mouse_position())
	
	if tilemap.get_cell(current_tile.x, current_tile.y) != tilemap.INVALID_CELL:
		show()
		position = tilemap.map_to_world(current_tile)
	
	else:
		hide()
