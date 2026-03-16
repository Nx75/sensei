extends Control

func _ready() -> void:
	MusicManager.stop_music()
	FirstBackground.play_music()
	pass
	
func _on_start_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://ui/level.tscn")
	pass
	 
func _on_quit_pressed() -> void:
	get_tree().quit()
