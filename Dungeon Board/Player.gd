extends Sprite

onready var tilemap = get_tree().root.get_child(0).get_node("TileMap")
var tile_index = 0


func _ready():
	position = tilemap.map_to_world(Vector2(0, 0))


# To do: basic movement
# Problem: All movement would happen instantly, not allowing for any animations
# Need to make 
func move(tiles : int = 1):
	for n in tiles:
		var directions = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]
		var current = tilemap.path[tile_index]
		var previous = tilemap.path[tile_index - 1]
		
		tile_index += 1
		var next_indexes = []
		for dir in directions:
			if tilemap.path.find(current - dir) != -1 && current - dir != previous:
				next_indexes.append(tilemap.path.find(current - dir))

		if next_indexes.size() > 1:
			print(next_indexes)
		else:
			tile_index = next_indexes[0]



func _process(delta):
	if Input.is_action_just_pressed("ui_select") && position == tilemap.map_to_world(tilemap.path[tile_index]):
		move()
	elif position != tilemap.map_to_world(tilemap.path[tile_index]):
		var target = tilemap.map_to_world(tilemap.path[tile_index])
		
		$Tween.interpolate_property(
			self, "position",
			position, target,
			0.05, Tween.TRANS_QUAD, Tween.EASE_IN_OUT
		)
		$Tween.start()
		
		if position.distance_to(target) < 0.35:
			position = target
			$Tween.stop_all()
	
