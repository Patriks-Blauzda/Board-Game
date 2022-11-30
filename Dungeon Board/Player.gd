extends Sprite

export var atk = 0
export var def = 1
export var eva = 1
export var hp = 40


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
	Global.game_active = true


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
	
		match tilemap.path[tile_index] - tilemap.path[previous_index]:
			Vector2(1, 0):
				$Dir.frame = 1
			Vector2(-1, 0):
				$Dir.frame = 2
			Vector2(0, 1):
				$Dir.frame = 3
			Vector2(0, -1):
				$Dir.frame = 0
		
		if Global.enemies.has(tilemap.get_cellv(tilemap.path[tile_index])):
			movement_points = 0
			
			get_owner().get_node("Combat").initialize_combat(self, tilemap.get_cellv(tilemap.path[tile_index]))
			
			tilemap.set_cellv(tilemap.path[tile_index], 0)
			
			camera.get_node("AnimationPlayer").play("Transition")
			camera.get_node("Hand").hide()
			Global.in_combat = true
		
		
		# Handles actions for different tiles (chest, spike trap, portal)
		match tilemap.get_cellv(tilemap.path[tile_index]):
			# Adds 1-2 random cards from all existing cards if player is holding less than 5 cards
			# Max hand size is 5
			# Player skips over the chest if hand is full
			3:
				var hand = camera.get_node("Hand")
				if hand.get_child_count() < 5:
					var rng = RandomNumberGenerator.new()
					rng.randomize()
					
					for _i in range(0, rng.randi_range(1, 2)):
						var card_to_add = rng.randi_range(0, 4)
						hand.add_card(card_to_add)
						
						if hand.card_list.size() > 4:
							break
					
					movement_points = 0
					tilemap.set_cellv(tilemap.path[tile_index], 0)
			
			# Spike trap removes 1 health from the player
			5:
				hp -= 1
			
			# Teleports player to other cell of same type (can only be two on the map)
			6:
				for i in tilemap.path:
					if tilemap.get_cellv(i) == 6 && i != tilemap.path[tile_index]:
						tile_index = tilemap.path.find(i)
						previous_index = tile_index
						break


# Plays after camera transition from/to combat
# If all enemies are defeated, game is won and victory screen is shown
func _on_AnimationPlayer_animation_finished(_anim_name):
	if camera.position.y != 0:
		get_owner().get_node("Combat").rolling = 240
	else:
		if tilemap.has_won():
			camera.get_node("Win").show()
			Global.game_active = false
			


func _physics_process(_delta):
	if Global.game_active:
		# If player is out of health, ends the game and displays death sprite
		if hp < 1 || get_owner().get_node("Combat/Player").hp < 1:
			camera.get_node("GameOver").show()
			Global.game_active = false
			frame = 3
			
		
		$SelectionVisual.hide()
		
		$Anchor/TextureRect/Label.text = "MP: " + str(movement_points)
		
		
		# Updates player stats every frame
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
				card_played = false
				mp_bonus = 0
			
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
		
		# Rolls dice every frame for a set period of time to decide the distance to move
		elif rolling != 0:
			if rolling > 40:
				$Anchor/Sprite.frame = Global.roll() - 1
			
			rolling -= 1
			
			if rolling == 40:
				movement_points = $Anchor/Sprite.frame + 1 + mp_bonus
		


# Begins rolling dice for movement if currently not moving
func _on_RollButton_pressed():
	if movement_points == 0:
		rolling = 80


# Toggles card window
func _on_Card_pressed():
	camera.get_node("Hand").visible = !camera.get_node("Hand").visible
