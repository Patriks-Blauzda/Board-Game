extends Sprite

onready var combat = get_owner()

var idle = true

var hp = 10
var atk = 1
var def = 2
var eva = 2
var initiative = 0

var action = -1
var target = null
var moused_over = -1

var turn = false

func _on_TextureButton_pressed():
	if target != null:
		action = combat.action.ATTACK


func _process(_delta):
	combat.get_node("PlayerStats/Atk").text = str(atk)
	combat.get_node("PlayerStats/Def").text = str(def)
	combat.get_node("PlayerStats/Eva").text = str(eva)
	combat.get_node("PlayerStats/Health/Hp").text = str(hp)
	
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


func _on_AnimationPlayer_animation_finished(anim_name):
	idle = true
	if anim_name != "Idle":
		get_owner().advanceturn()


func _on_Area2D_mouse_exited():
	moused_over = -1
