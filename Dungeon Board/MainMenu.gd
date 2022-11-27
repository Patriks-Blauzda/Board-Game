extends Control


func _on_TextureButton_pressed():
	var _scene = get_tree().change_scene_to(load("res://Main.tscn"))


func _on_TextureButton2_pressed():
	get_tree().quit()
