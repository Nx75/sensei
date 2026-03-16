extends Area2D

func _on_body_entered(body):
	if body.name == "Player" or body.is_in_group("Player"):
		get_tree().call_deferred("reload_current_scene")
