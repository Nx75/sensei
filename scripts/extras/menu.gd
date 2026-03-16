extends Control

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/misc_scenes/game.tscn")
	pass
	 
func _on_options_pressed() -> void:
	pass 
	
func _on_quit_pressed() -> void:
	get_tree().quit()
