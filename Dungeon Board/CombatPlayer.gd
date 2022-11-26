extends Sprite

onready var combat = get_owner()

var idle = true

var hp = 100
var atk = 2
var def = 5
var eva = 3
var initiative = 0

var action = -1
var target = null
var moused_over = -1

var turn = false


func _process(_delta):
	combat.get_node("PlayerStats/Atk").text = str(atk)
	combat.get_node("PlayerStats/Def").text = str(def)
	combat.get_node("PlayerStats/Eva").text = str(eva)
	combat.get_node("PlayerStats/Health/Hp").text = str(hp)
	
	if turn && action != 2:
		combat.get_node("Actions").show()
		
		for i in range(1, 4):
			var selectedenemy = combat.get_node("Enemy" + str(i))
			selectedenemy.self_modulate = Color(1, 1, 1)
			selectedenemy.get_node("Health").hide()

			if i == moused_over:
				selectedenemy.self_modulate = Color(0.921569, 1, 0)
				selectedenemy.get_node("Health").show()

				get_owner().get_node("EnemyStats/Atk").text = str(selectedenemy.atk)
				get_owner().get_node("EnemyStats/Def").text = str(selectedenemy.def)
				get_owner().get_node("EnemyStats/Eva").text = str(selectedenemy.eva)
	else:
		combat.get_node("Actions").hide()
	
	
	if target != null && target.idle:
		target.self_modulate = Color(0.109804, 1, 0.219608)
	
	
	if idle:
		$AnimationPlayer.play("Idle")
		
	if ![-1, 2].has(action) && turn:
		combat.advanceturn()


func _on_Area2D_input_event(_viewport, event, _shape_idx, extra_arg_0):
	if event is InputEventMouseMotion:
		moused_over = extra_arg_0
	
	if event is InputEventMouseButton:
		if !event.pressed && event.button_index == 1:
			target = combat.get_node("Enemy" + str(extra_arg_0))


func _on_AnimationPlayer_animation_finished(anim_name):
	idle = true
	if ["Attack1", "Attack2", "Attack3"].has(anim_name):
		
		
		get_owner().advanceturn()


func _on_Area2D_mouse_exited():
	moused_over = -1


func _on_Button_pressed(extra_arg_0):
	match extra_arg_0:
		0:
			if target != null:
				action = combat.action.ATTACK
				combat.attack(self, target)
				
				target = null
		1:
			action = combat.action.DEFEND
		2:
			action = combat.action.EVADE
		3:
			pass
	
	target = null
