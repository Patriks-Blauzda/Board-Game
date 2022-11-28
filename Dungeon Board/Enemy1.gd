extends Sprite

# Enemy1/2/3 are the same, except for animations, so only this file will be commented

var idle = true

var in_combat = true

var hp = 12
var atk = 2
var def = 0
var eva = 0
var initiative = 0

var action = -1

var turn = false

# Carries out turn with probability based on own stats (defense and evasion)
func do_turn():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var probability = rng.randi_range(0, 99)
	
	if probability <= 44:
		action = get_owner().action.ATTACK
		
	elif probability <= clamp(33 + (33 * (def / eva)), 48, 84):
		action = get_owner().action.DEFEND
		
	else:
		action = get_owner().action.EVADE
		
	
	if action == get_owner().action.ATTACK:
		get_owner().attack(self, get_owner().get_node("Player"))
	else:
		get_owner().advanceturn()

# If the attack animation is finished, advances turn order
func _on_AnimationPlayer_animation_finished(anim_name):
	idle = true
	if anim_name == "Attack":
		get_owner().advanceturn()


func _process(_delta):
	$Health/Hp.text = str(hp)
	
	# Makes sure enemy appears correctly
	if in_combat:
		if hp > 0:
			show()
			get_owner().get_node("Corpse1").hide()
			
			if idle:
				$AnimationPlayer.play("Idle")
			
		elif !$AnimationPlayer.is_playing():
			hide()
			get_owner().get_node("Corpse1").show()
			
			if get_owner().turnorder.has(self):
				get_owner().turnorder.remove(get_owner().turnorder.find(self))
				
	else:
		hide()
		get_owner().get_node("Corpse1").hide()
