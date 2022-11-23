extends Sprite

export var atk = 4
export var def = 2
export var eva = 2
export var hp = 10

onready var tilemap = get_owner().get_node("TileMap")
onready var camera = get_owner().get_node("Camera2D")

var rng = RandomNumberGenerator.new()

var previous_index = 0
var tile_index = 0

var movement_points = 0

var rolling = 0


func _ready():
	position = tilemap.map_to_world(tilemap.path[tile_index])
	OS.center_window()


# Updates the player's target position
# If there are multiple directions the player can move in, all movement will be halted until
# the player chooses the direction
func move():
	# Variables to store the Vector2 values of tiles
	var current = tilemap.path[tile_index]
	var previous = tilemap.path[previous_index]
	
	# Stores potential tiles to move to
	var next_indexes = []
	for dir in Global.directions:
		if tilemap.path.find(current - dir) != -1 && current - dir != previous:
			next_indexes.append(tilemap.path.find(current - dir))
	
	# If there are more than one possible tiles to move to, the player is prompted
	if next_indexes.size() > 1:
		$SelectionVisual.show()
		
		previous_index = tile_index
		
		# (Temporary) Checks the player's inputs and saves them as a Vector2
		var player_selection = (Vector2(
			int(Input.is_action_just_pressed("right")) - int(Input.is_action_just_pressed("left")),
			int(Input.is_action_just_pressed("down")) - int(Input.is_action_just_pressed("up")))
		)
		
		var target = current + player_selection
		
		if Input.is_mouse_button_pressed(1):
			target = tilemap.world_to_map(get_global_mouse_position())
		
		# Finds the target tile in the path array
		if next_indexes.has(tilemap.path.find(target)):
			tile_index = tilemap.path.find(target)
	
	# If there is one direction to move it, goes there. If there are none, turns the player around
	else:
		previous_index = tile_index
		
		if !next_indexes.empty():
			tile_index = next_indexes[0]
	
	# As long as the player has moved, takes away one movement point
	if tile_index != previous_index:
		movement_points -= 1



# Rolls 6 sided die specified amount of times, returns sum
func roll(times : int):
	rng.randomize()
	
	var sum = 0
	
	for n in times:
		sum += rng.randi_range(1, 6)
	
	return sum


func _physics_process(_delta):
	$SelectionVisual.hide()
	
	$Anchor/TextureRect/Label.text = "MP: " + str(movement_points)
	
	
	# Will be updated when other parts of the game are done
	if movement_points > 0 && position == tilemap.map_to_world(tilemap.path[tile_index]) && rolling == 0:
		move()
		
		if Global.enemies.has(tilemap.get_cellv(tilemap.path[tile_index])):
			movement_points = 0
		
	# Animates the player moving from one tile to another
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
	
	elif rolling != 0:
		if rolling > 40:
			rng.randomize()
			$Anchor/Sprite.frame_coords = Vector2(rng.randi_range(0, 2), rng.randi_range(0, 1))
		
		rolling -= 1
		
		if rolling == 40:
			movement_points += $Anchor/Sprite.frame + 1
		


func _on_RollButton_pressed():
	if movement_points == 0:
		rolling = 80
