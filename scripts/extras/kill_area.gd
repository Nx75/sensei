extends Area2D
var is_dead: bool = false

func _on_kill_area_body_entered(body):
	if is_dead:
		return
	
	if body.has_method("die"):
		print("Ghost killed player!")
		body.die()
