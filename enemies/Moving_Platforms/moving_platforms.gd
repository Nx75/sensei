extends Path2D
class_name Movingplatform 

@export var path_follow_2d :PathFollow2D
@export var Total_time=1.0
@export var looping = false 
@export var ease : Tween.EaseType
@export var transition : Tween.TransitionType


func _ready() -> void:
	move_tween()
	
	pass

func move_tween():
	var tween =get_tree().create_tween().set_loops()
	tween.tween_property(path_follow_2d,"progress_ratio",1,Total_time)
	if !looping:
		tween.tween_property(path_follow_2d,"progress_ratio",0,Total_time)
	else:
		tween.tween_property(path_follow_2d,"progress_ratio",0,0)
		
	pass
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
