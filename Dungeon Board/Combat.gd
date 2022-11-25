extends Node2D

var enemycount = 1

var battle_start = true

enum action {
	SKIP = -1
	DEFEND = 0
	EVADE = 1
	ATTACK = 2
}

var rolling = 140

var turnorder = []


# Attack from unit to target, called from AnimationPlayer of the attacker
func attack(attacker: Node, target: Node):
	attacker.idle = false
	target.idle = false
	
	var dmg = attacker.atk + Global.roll()
	
	
	if attacker.name == "Player":
		attacker.get_node("AnimationPlayer").play("Attack" + target.name[target.name.length() - 1])
	else:
		attacker.get_node("AnimationPlayer").play("Attack")
	
	
	match target.action:
		action.SKIP:
			target.hp -= dmg
			
			target.get_node("AnimationPlayer").play("TakeDamage")
			
		action.DEFEND:
			var def = target.def + Global.roll()
			
			target.hp -= clamp((dmg - def), 1, 999)
			
			target.get_node("AnimationPlayer").play("Defend")
		
		action.EVADE:
			var eva = target.eva + Global.roll()
			
			if eva < dmg:
				target.hp -= dmg
				target.get_node("AnimationPlayer").play("TakeDamage")
			else:
				target.get_node("AnimationPlayer").play("Evade")


func advanceturn():
	for i in range(turnorder.size() - 1):
		if turnorder[i].turn:
			if i < turnorder.size() - 1:
				turnorder[i].turn = false
				turnorder[i + 1].turn = true
			else:
				turnorder[i].turn = false
				turnorder[0].turn = true


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


func get_current_turn():
	for i in turnorder:
		if i.turn:
			return i


func _process(_delta):
	if !turnorder.empty():
		$Turn.text = str(get_current_turn().get_name()) + "'s Turn"
	
	
		var is_turn_finished = true
		for i in turnorder:
			if i.get_node("AnimationPlayer").current_animation != "Idle":
				is_turn_finished = false
	
		if is_turn_finished && get_current_turn().name != "Player":
			get_current_turn().do_turn()
	
	
	if rolling != 0:
		if rolling > 80:
			for i in [$Player, $Enemy1, $Enemy2, $Enemy3]:
				if i.visible:
					i.get_node("Dice").frame = Global.roll() - 1
		
		rolling -= 1
		
		if rolling == 80:
			for i in [$Player, $Enemy1, $Enemy2, $Enemy3]:
				if i.visible:
					i.initiative = i.get_node("Dice").frame + 1
					turnorder.append(i)
					
			sortinitiative()
			
			turnorder[0].turn = true
	
	else:
		for i in [$Player, $Enemy1, $Enemy2, $Enemy3]:
			i.get_node("Dice").hide()
