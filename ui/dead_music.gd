extends Node2D 

@onready var audio_player2  = $Dead
func _ready():
	play_music()

func play_music():
	audio_player2.play()
func stop_music():
	audio_player2.stop()
