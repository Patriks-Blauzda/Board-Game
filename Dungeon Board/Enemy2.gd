extends Sprite

var idle = true

var in_combat = false

var hp = 10
var atk = 2
var def = 2
var eva = 2
var initiative = 0

var action = -1

var turn = false

func _on_AnimationPlayer_animation_finished(anim_name):
	idle = true
	if anim_name != "Idle":
		get_owner().advanceturn()

func _process(_delta):
	$Health/Hp.text = str(hp)
	
	if in_combat:
		if hp > 0:
			show()
			get_owner().get_node("Corpse2").hide()
			
			if idle:
				$AnimationPlayer.play("Idle")
			
		elif !$AnimationPlayer.is_playing():
			hide()
			get_owner().get_node("Corpse2").show()
	else:
		hide()
		get_owner().get_node("Corpse2").hide()
