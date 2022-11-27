extends Node

# Global script, contents can be called from anywhere (for example, in TileMap.gd, 'Global.directions')

func _ready():
	OS.center_window()

var game_active = false

# The directions the player can move in (right, left, up, down)
const directions : Array = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, -1), Vector2(0, 1)]

# Tiles that contain enemies
const enemies : Array = [1, 2]

var turn = 0
var current_floor = 0

var in_combat = false


var rng = RandomNumberGenerator.new()

# Rolls 6 sided die specified amount of times, returns sum
func roll(times: int = 1):
	rng.randomize()
	
	var sum = 0
	
	for n in times:
		sum += rng.randi_range(1, 6)
	
	return sum
