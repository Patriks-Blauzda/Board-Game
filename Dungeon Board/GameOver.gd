extends TextureRect


func _on_Retry_pressed():
	get_tree().paused = false
	var _reload = get_tree().reload_current_scene()
