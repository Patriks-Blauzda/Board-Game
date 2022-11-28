extends HBoxContainer

onready var card_source = load("res://Card.tscn")

onready var player = get_owner().get_node("Player")
onready var combatplayer = get_owner().get_node("Combat/Player")

var card_list = []

var combat_cards = [0, 2, 4]
var board_cards = [1, 3]


func add_card(card_index):
	var card = card_source.instance()
	var card_self = card
	
	card.texture_normal = card.texture_normal.duplicate()
	
	card.texture_normal.region.position.x = clamp(126 + (95 * card_index), 126, 506)
	
	add_child(card)
	card.connect("pressed", self, "_on_Card_Pressed", [card_index, card_self])
	
	card_list.append(card)


func remove_card(child_index):
	card_list[child_index].disconnect("pressed", self, "_on_Card_Pressed")
	card_list[child_index].queue_free()
	card_list.remove(child_index)


func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	add_card(combat_cards[rng.randi_range(0,2)])
	
	hide()


func _on_Card_Pressed(card_index, card_self):
	if combat_cards.has(card_index) && Global.in_combat && !combatplayer.card_played:
		match card_index:
			0:
				combatplayer.bonus_atk = 1
			2:
				combatplayer.bonus_atk = 2
				combatplayer.bonus_def = -2
			4:
				combatplayer.bonus_def = -2
				combatplayer.bonus_eva = 3
		
		combatplayer.card_played = true
		hide()
		remove_card(card_list.find(card_self))
	
	
	elif board_cards.has(card_index) && !Global.in_combat && !player.card_played && player.movement_points == 0:
		match card_index:
			1:
				player.hp += 1
			3:
				player.mp_bonus = 5
		
		player.card_played = true
		hide()
		remove_card(card_list.find(card_self))
