extends Node

# Global script, contents can be called from anywhere (for example, in TileMap.gd, 'Global.directions')

# The directions the player can move in (right, left, up, down)
const directions : Array = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, -1), Vector2(0, 1)]

const enemies : Array = [1, 2]

var turn = 0
var current_floor = 0
