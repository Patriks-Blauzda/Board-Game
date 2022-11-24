extends Sprite

var idle = true

var hp = 10
var dmg = 2
var def = 2
var eva = 2
var initiative = 0

var action = 0


func _on_AnimationPlayer_animation_finished(anim_name):
	idle = true
