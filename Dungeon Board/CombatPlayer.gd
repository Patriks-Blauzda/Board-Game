extends Sprite

onready var combat = get_owner()

var idle = true

var hp = 40
var atk = 0
var def = 1
var eva = 1
var initiative = 0

var bonus_atk = 0
var bonus_def = 0
var bonus_eva = 0

var action = -1
var target = null
var moused_over = -1

var turn = false

var card_played = false
var card_duration = 2

# Reset bonus stats from cards, used in Combat.gd
func reset_bonus():
	bonus_atk = 0
	bonus_def = 0
	bonus_eva = 0


func _process(_delta):
	# Shows death sprite and stops game on death
	if hp < 1:
		frame = 3
		$AnimationPlayer.stop()
		combat.get_node("Actions").hide()
	
	combat.get_node("PlayerStats/Atk").text = str(atk + bonus_atk)
	combat.get_node("PlayerStats/Def").text = str(def + bonus_def)
	combat.get_node("PlayerStats/Eva").text = str(eva + bonus_eva)
	combat.get_node("PlayerStats/Health/Hp").text = str(hp)
	
	# Colors the enemies if player is moused over them or has targeted them
	if turn && action != 2 && hp > 1:
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
	
	
	# Colors target green for easier visibility of target
	if target != null && target.idle && idle && turn:
		target.self_modulate = Color(0.109804, 1, 0.219608)
	
	if idle:
		$AnimationPlayer.play("Idle")
		
	if ![-1, 2].has(action) && turn:
		combat.advanceturn()


# Checks if enemy has been moused over or clicked on
func _on_Area2D_input_event(_viewport, event, _shape_idx, extra_arg_0):
	if event is InputEventMouseMotion:
		moused_over = extra_arg_0
	
	if event is InputEventMouseButton:
		if !event.pressed && event.button_index == 1 && idle && turn:
			target = combat.get_node("Enemy" + str(extra_arg_0))


# If attack animation is finished, advances turn
func _on_AnimationPlayer_animation_finished(anim_name):
	idle = true
	if ["Attack1", "Attack2", "Attack3"].has(anim_name):
		
		get_owner().advanceturn()


func _on_Area2D_mouse_exited():
	moused_over = -1


# Handles player actions from the button display
func _on_Button_pressed(extra_arg_0):
	match extra_arg_0:
		0:
			if target != null:
				target.self_modulate = Color(1, 1, 1)
				action = combat.action.ATTACK
				
				combat.attack(self, target)
		1:
			action = combat.action.DEFEND
		2:
			action = combat.action.EVADE
	
	target = null	
