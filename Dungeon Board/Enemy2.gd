extends Sprite

var idle = true

var hp = 10
var dmg = 2
var def = 2
var eva = 2
var initiative = 0

var action = -1


func _on_AnimationPlayer_animation_finished(_anim_name):
	idle = true

func _process(_delta):
	$Health/Hp.text = str(hp)
	
	if hp > 0:
		show()
		get_owner().get_node("Corpse2").hide()
		
		if idle:
			$AnimationPlayer.play("Idle")
		
	elif !$AnimationPlayer.is_playing():
		hide()
		get_owner().get_node("Corpse2").show()
