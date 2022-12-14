extends Node2D

var initialized = false

enum action {
	SKIP = -1
	DEFEND = 0
	EVADE = 1
	ATTACK = 2
}

var rolling = 0

var turnorder = []


# Resets values upon combat beginning, transfers player stats from board to battle window,
# decides the enemy amount and initializes them
func initialize_combat(playernode: Node, tileid: int):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	$Player.hp = playernode.hp
	$Player.atk = playernode.atk
	$Player.def = playernode.def
	$Player.eva = playernode.eva
	$Player/Dice.show()
	$Player.card_played = false
	
	$Player.reset_bonus()
	
	# Depending on tile, spawns enemies with randomized values
	# Health is dependant on stats, i.e. if an enemy has 3 atk, 6 def and 6 eva, it has 1 hp
	if tileid == 1:
		var target = get_node("Enemy1")
		
		target.def = Global.roll()
		target.eva = Global.roll()
		target.atk = ceil((Global.roll() - 1) / 2)
		target.hp = 16 - (target.def + target.atk + target.eva)
		
		target.in_combat = true
		target.get_node("Dice").show()
		
	else:
		for i in range(1, rng.randi_range(3, 4)):
			var target = get_node("Enemy" + str(i))
			
			target.def = Global.roll()
			target.eva = Global.roll()
			target.atk = ceil((Global.roll() - 1) / 2)
			target.hp = 16 - (target.def + target.atk + target.eva)
			
			target.in_combat = true
			target.get_node("Dice").show()
	
	# On combat start, displays enemy1 stats by default
	$EnemyStats/Atk.text = str(get_node("Enemy1").atk)
	$EnemyStats/Def.text = str(get_node("Enemy1").def)
	$EnemyStats/Eva.text = str(get_node("Enemy1").eva)
	
	
	initialized = true


# On combat end, transfers player battle stats to board stats and resets all battle values
func end_combat(playernode: Node):
	$Player.turn = false
	$Player/Dice.hide()
	$Player.action = -1
	$Player.card_played = false
	$Player.card_duration = 2
	
	playernode.hp = $Player.hp
	playernode.atk = $Player.atk
	playernode.def = $Player.def
	playernode.eva = $Player.eva
	
	for i in range(1, 4):
		var target = get_node("Enemy" + str(i))
		target.action = -1
		target.in_combat = false
		target.turn = false
		target.get_node("Dice").hide()
	
	
	$DmgNum/AttackerDice.hide()
	$DmgNum/TargetDice.hide()
	
	Global.in_combat = false
	turnorder = []


# Attack from unit to target, called from AnimationPlayer of the attacker
func attack(attacker: Node, target: Node):
	attacker.idle = false
	target.idle = false
	
	$DmgNum/AttackerDice.show()
	$DmgNum/TargetDice.show()
	
	if target.action == action.ATTACK:
		target.action = action.SKIP
	
	
	$DmgNum/AttackerDice.frame = Global.roll() - 1
	var dmg = attacker.atk + $DmgNum/AttackerDice.frame + 1
	
	# Player attack animation handled  separately, since attack animations for targeting each enemy
	# are different
	if attacker.name == "Player":
		attacker.get_node("AnimationPlayer").play("Attack" + target.name[target.name.length() - 1])
		dmg += attacker.bonus_atk
	else:
		attacker.get_node("AnimationPlayer").play("Attack")
	
	$DmgNum.text = "Dealt " + str(dmg) + " Damage"
	
	
	# Based on the target's action, rolls for def or evasion, or if idle/skipped turn, nothing
	match target.action:
		action.SKIP:
			target.hp -= dmg
			
			target.get_node("AnimationPlayer").play("TakeDamage")
			
		action.DEFEND:
			$DmgNum/TargetDice.frame = Global.roll() - 1
			var def = $DmgNum/TargetDice.frame + 1 + target.def
			
			if target.name == "Player":
				def += target.bonus_def
			
			$DmgNum.text = "Blocked! Dealt " + str(clamp(dmg - def - 1, 1, 99)) + " Damage"
			
			target.hp -= clamp(dmg - def - 1, 1, 99)
			
			target.get_node("AnimationPlayer").play("Defend")
			
			$DmgNum.text += "\n" + str(dmg) + " damage vs " + str(def) + " defense"
		
		action.EVADE:
			$DmgNum/TargetDice.frame = Global.roll() - 1
			var eva = $DmgNum/TargetDice.frame + 1 + target.eva
			
			if target.name == "Player":
				eva += target.bonus_eva
			
			if eva <= dmg:
				target.hp -= dmg
				target.get_node("AnimationPlayer").play("TakeDamage")
			
			else:
				target.get_node("AnimationPlayer").play("Evade")
				
				$DmgNum.text = "Missed!"
				
			$DmgNum.text += "\n" + str(dmg) + " damage vs " + str(eva) + " evasion"


# Advances the turn based on turn order array and resets the selected action
# If player has a card active, on player turn start either lowers its turn duration variable
# or disables the stat bonuses
func advanceturn():
	for i in range(turnorder.size()):
		if turnorder[i].turn:
			if turnorder[i].name == "Player":
				if turnorder[i].card_duration == 0:
					turnorder[i].reset_bonus()
				else:
					turnorder[i].card_duration -= 1
			
			if i < turnorder.size() - 1:
				turnorder[i].turn = false
				turnorder[i + 1].turn = true
				
			else:
				turnorder[i].turn = false
				turnorder[0].turn = true
			
			get_current_turn().action = -1
			break


# Sorts turn order based on initiative in ascending order
func sortinitiative():
	var is_sorted = false
	
	while !is_sorted:
		is_sorted = true
		
		for i in range(turnorder.size() - 1):
			if turnorder[i].initiative < turnorder[i + 1].initiative:
				var temp = turnorder[i]
				
				turnorder[i] = turnorder[i + 1]
				turnorder[i + 1] = temp
				
				is_sorted = false


# Returns the node path of the node if it's their turn
func get_current_turn():
	for i in turnorder:
		if i.turn:
			return i
	
	return null


# On ready, ends combat to make sure all values are their defaults
func _ready():
	for i in [$Player, $Enemy1, $Enemy2, $Enemy3]:
			i.get_node("Dice").hide()

	end_combat(get_owner().get_node("Player"))


func _process(_delta):
	if Global.game_active:
		if get_current_turn() != null:
			$Turn.text = str(get_current_turn().get_name()) + "'s Turn"
		
			# Stops enemies from carrying out their turn before animations are finished
			var is_turn_finished = true
			for i in turnorder:
				if i.get_node("AnimationPlayer").current_animation != "Idle":
					is_turn_finished = false
		
			if is_turn_finished && get_current_turn().name != "Player":
				for i in turnorder:
					if i.get_node("AnimationPlayer").current_animation == "Idle":
						get_current_turn().do_turn()
						break
			
			# If the turnorder array only has one node (the player), ends combat and counts it as a win
			if turnorder.size() == 1:
				get_owner().get_node("Camera2D/StatUp").show()
				$Player.reset_bonus()
				turnorder.clear()
				$Player.turn = false
		
		
		# Rolls dice for initiative at combat start for player and every active enemy
		if rolling != 0:
			if rolling > 160:
				for i in [$Player, $Enemy1, $Enemy2, $Enemy3]:
					if i.visible:
						i.get_node("Dice").frame = Global.roll() - 1
			
			rolling -= 1
			
			if rolling == 160:
				for i in [$Player, $Enemy1, $Enemy2, $Enemy3]:
					if i.visible:
						i.initiative = i.get_node("Dice").frame + 1
						turnorder.append(i)
						
				sortinitiative()
		
		elif $Player/Dice.visible && !turnorder.empty():
				for i in [$Player, $Enemy1, $Enemy2, $Enemy3]:
					i.get_node("Dice").hide()
				
				turnorder[0].turn = true
	else:
		$Actions.hide()


# Upgrades specified stat or heals player by 5 after combat is finished
# Returns player to board afterwards
func _on_StatUp_pressed(extra_arg_0):
	match extra_arg_0:
		0:
			$Player.atk += 1 
		1:
			$Player.def += 1
		2:
			$Player.eva += 1
		3:
			$Player.hp += 5
	
	end_combat(get_owner().get_node("Player"))
	get_owner().get_node("Camera2D/StatUp").hide()
	get_owner().get_node("Camera2D/AnimationPlayer").play_backwards("Transition")
