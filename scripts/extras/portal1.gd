extends Area2D

@export var destination: Marker2D
@onready var portal_sound: AudioStreamPlayer2D =$op

func _on_body_entered(body: Node2D) -> void:
	portal_sound.play()
	if body.name == "Player":
		
		call_deferred("_go_to_next_level")

func _go_to_next_level():
	get_tree().change_scene_to_file("res://scenes/levels/level_2.tscn")
