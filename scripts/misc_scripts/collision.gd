extends Area2D

func _on_body_entered(body):
	if body.name == "Player" or body.is_in_group("Player"):
		get_tree().call_deferred("change_scene_to_file", "res://scenes/misc_scenes/end_screen.tscn")
