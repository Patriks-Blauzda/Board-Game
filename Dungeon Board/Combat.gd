extends Node2D

var enemycount = 1


enum action {
	SKIP = -1
	DEFEND = 0
	EVADE = 1
	ATTACK = 2
}


# Attack from unit to target, called from AnimationPlayer of the attacker
func attack(attacker: Node, target: Node):
	attacker.idle = false
	target.idle = false
	
	var dmg = attacker.dmg + Global.roll()
	
	
	if attacker.name == "Player":
		attacker.get_node("AnimationPlayer").play("Attack" + target.name[target.name.length() - 1])
	
	
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


