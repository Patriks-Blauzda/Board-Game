extends Sprite

var idle = true

var in_combat = true

var hp = 10
var atk = 2
var def = 2
var eva = 2
var initiative = 0

var action = -1

var turn = false

func _on_AnimationPlayer_animation_finished(anim_name):
	idle = true
	if anim_name != "Idle" && anim_name != "Attack":
		get_owner().advanceturn()


func do_turn():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	action = rng.randi_range(0, 2)
	
	get_owner().attack(self, get_owner().get_node("Player"))


func _process(_delta):
	$Health/Hp.text = str(hp)
	
	if in_combat:
		if hp > 0:
			show()
			get_owner().get_node("Corpse1").hide()
			
			if idle:
				$AnimationPlayer.play("Idle")
			
		elif !$AnimationPlayer.is_playing():
			hide()
			get_owner().get_node("Corpse1").show()
	else:
		hide()
		get_owner().get_node("Corpse1").hide()
