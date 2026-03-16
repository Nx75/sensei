extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		DeadMusic.play_music()
		get_tree().call_deferred("change_scene_to_file", "res://ui/death_SCREEN.tscn")
