extends Sprite

export var atk = 3
export var def = 6
export var eva = 6
export var hp = 35



onready var tilemap = get_owner().get_node("TileMap")
onready var camera = get_owner().get_node("Camera2D")

var previous_index = 0
var tile_index = 0

var movement_points = 0
var mp_bonus = 0

var rolling = 0

var card_played = false

func _ready():
	position = tilemap.map_to_world(tilemap.path[tile_index]) + Vector2(250, 300)
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
		
		if Global.enemies.has(tilemap.get_cellv(tilemap.path[tile_index])):
			movement_points = 0
			
			get_owner().get_node("Combat").initialize_combat(self, tilemap.get_cellv(tilemap.path[tile_index]))
			
			tilemap.set_cellv(tilemap.path[tile_index], 0)
			
			camera.get_node("AnimationPlayer").play("Transition")
			camera.get_node("Hand").hide()
			Global.in_combat = true
		
		
		match tilemap.get_cellv(tilemap.path[tile_index]):
			5:
				hp -= 1
				
			6:
				for i in tilemap.path:
					if tilemap.get_cellv(i) == 6 && i != tilemap.path[tile_index]:
						tile_index = tilemap.path.find(i)
						previous_index = tile_index
						break



func _on_AnimationPlayer_animation_finished(_anim_name):
	if camera.position.y != 0:
		get_owner().get_node("Combat").rolling = 240


func _physics_process(_delta):
	$SelectionVisual.hide()
	
	$Anchor/TextureRect/Label.text = "MP: " + str(movement_points)
	
	
	$Anchor/PlayerStats/Atk.text = str(atk)
	$Anchor/PlayerStats/Def.text = str(def)
	$Anchor/PlayerStats/Eva.text = str(eva)
	$Anchor/PlayerStats/Health/Hp.text = str(hp)
	
	
	if camera.get_node("Hand").get_child_count() > 0 && !card_played && !get_owner().get_node("Combat/Player").card_played:
		$Anchor/Card.disabled = false
		get_owner().get_node("Combat/Actions/Card").disabled = false
	else:
		$Anchor/Card.disabled = true
		get_owner().get_node("Combat/Actions/Card").disabled = true
	
	
	# Will be updated when other parts of the game are done
	if movement_points > 0 && position == tilemap.map_to_world(tilemap.path[tile_index]) && rolling == 0:
		move()
		
		if movement_points == 0:
			Global.turn += 1
			print(Global.turn)
			card_played = false
		
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
			$Anchor/Sprite.frame = Global.roll() - 1
		
		rolling -= 1
		
		if rolling == 40:
			movement_points = $Anchor/Sprite.frame + 1 + mp_bonus
	


func _on_RollButton_pressed():
	if movement_points == 0:
		rolling = 80


func _on_Card_pressed():
	camera.get_node("Hand").visible = !camera.get_node("Hand").visible
