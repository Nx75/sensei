extends CharacterBody2D

const SPEED = 80.0
const JUMP_VELOCITY = -400.0
var direction = 1
var state = "idle"
var is_dead: bool = false
@export var frog_health: int = 1
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if  is_on_floor():
		# stop if is on the floor
		velocity.x = 0
		$AnimatedSprite2D.play("idle")
		
	else:
		# Add the gravity and move horizontally if is on air. 
		velocity.x = direction * SPEED
		velocity.y += gravity * delta
		if velocity.y > 0:
			$AnimatedSprite2D.play("fall")
		else:
			$AnimatedSprite2D.play("jump")

	move_and_slide()
	
	# flip sprite
	$AnimatedSprite2D.flip_h = direction >0
	
	
func jump():
	velocity.y = JUMP_VELOCITY
	

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
			frog_take_damage()
			
			
			if body.has_method("bounce"):
				body.bounce(300)

func is_player_above(body):
	return body.global_position.y < global_position.y

func frog_take_damage():
	frog_health -= 1
	if frog_health <= 0:
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
	
	


func _on_timer_timeout():
	# when timer finish, change direction and jump
	direction *= -1
	jump()
