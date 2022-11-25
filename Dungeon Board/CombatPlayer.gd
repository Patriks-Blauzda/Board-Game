extends Sprite

onready var combat = get_owner()

var idle = true

var hp = 10
var dmg = 2
var def = 2
var eva = 2
var initiative = 0

var action = -1
var target = null
var moused_over = -1


func _on_TextureButton_pressed():
	action = combat.action.ATTACK


func _physics_process(_delta):
	for i in range(1, 4):
		combat.get_node("Enemy" + str(i)).self_modulate = Color(1, 1, 1)
		
		if i == moused_over:
			combat.get_node("Enemy" + str(i)).self_modulate = Color(0.921569, 1, 0)
	
	if target != null:
		target.self_modulate = Color(0.109804, 1, 0.219608)
	
	
	if idle:
		$AnimationPlayer.play("Idle")
		
	if action == combat.action.ATTACK && target != null:
		combat.attack(self, target)
		
		action = -1
		target = null


func _on_Area2D_input_event(_viewport, event, _shape_idx, extra_arg_0):
	if event is InputEventMouseMotion:
		moused_over = extra_arg_0
	
	if event is InputEventMouseButton:
		if !event.pressed && event.button_index == 1:
			target = combat.get_node("Enemy" + str(extra_arg_0))


func _on_AnimationPlayer_animation_finished(_anim_name):
	idle = true


func _on_Area2D_mouse_exited():
	moused_over = -1
