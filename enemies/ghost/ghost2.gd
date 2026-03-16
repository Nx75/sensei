extends CharacterBody2D

@export var speed: float = 70.0
@export var float_strength: float = 60.0
@export var float_speed: float = 1.5
@export var ghost_health: int = 1

var move_direction: int = 1
var time: float = 0.0
var distance_moved: float = 0.0
var is_dead: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
	if sprite:
		if sprite.sprite_frames and sprite.sprite_frames.has_animation("float"):
			sprite.play("float")
		else:
			sprite.visible = true

func _physics_process(delta):
	if is_dead:
		return
	
	time += delta
	distance_moved += abs(speed * delta)
	
	if distance_moved >= 180:
		move_direction *= -1
		distance_moved = 0
		if sprite:
			sprite.flip_h = move_direction < 0
	
	velocity.x = speed * move_direction
	velocity.y = cos(time * float_speed) * float_strength
	
	move_and_slide()
	
func spawn_feedback():
	var scene_to_spawn = preload("res://pickups/Feedback/feedback.tscn")
	var new_scene_instance = scene_to_spawn.instantiate()
	get_tree().current_scene.add_child(new_scene_instance)  # Add the instance as a child of the current scene
	new_scene_instance.global_position = global_position
	

func _on_kill_area_body_entered(body):
	if is_dead:
		return
	
	if body.has_method("die"):
		print("Ghost killed player!")
		body.die()


func _on_weak_spot_body_entered(body):
	if is_dead:
		return
	
	if body.name == "Player":
		print("Player hit ghost's weak spot!")
		
		if is_player_above(body):
			spawn_feedback()
			ghost_take_damage()
			
			
			if body.has_method("bounce"):
				body.bounce(300)

func is_player_above(body):
	return body.global_position.y < global_position.y

func ghost_take_damage():
	ghost_health -= 1
	if ghost_health <= 0:
		ghost_die()

func ghost_die():
	is_dead = true
	
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0, 0.5)
		await tween.finished
	
	queue_free()
