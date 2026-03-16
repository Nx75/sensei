extends CharacterBody2D

@export var speed: float = 120.0
@export var float_strength: float = 40.0
@export var float_speed: float = 2.0
@export var boss_health: int = 10

var time: float = 0.0
var move_direction: int = 1
var is_dead: bool = false
var boss_phase: int = 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
	if sprite and sprite.sprite_frames.has_animation("float"):
		sprite.play("float")


func _physics_process(delta):
	if is_dead:
		return

	time += delta
	
	update_phase()

	# Vertical boss movement (inverse of your original)
	velocity.y = speed * move_direction
	
	# Horizontal floating movement
	velocity.x = sin(time * float_speed) * float_strength

	move_and_slide()

	# Change vertical direction randomly
	if randi() % 120 == 0:
		move_direction *= -1


func update_phase():
	if boss_health <= 6:
		boss_phase = 2
		speed = 160
		float_strength = 60
	
	if boss_health <= 3:
		boss_phase = 3
		speed = 220
		float_strength = 90


func spawn_feedback():
	var scene_to_spawn = preload("res://pickups/Feedback/feedback.tscn")
	var new_scene_instance = scene_to_spawn.instantiate()
	get_tree().current_scene.add_child(new_scene_instance)
	new_scene_instance.global_position = global_position


func _on_kill_area_body_entered(body):
	if is_dead:
		return

	if body.has_method("die"):
		body.die()


func _on_weak_spot_body_entered(body):
	if is_dead:
		return

	if body.name == "Player":
		if is_player_above(body):

			spawn_feedback()
			boss_take_damage()

			if body.has_method("bounce"):
				body.bounce(350)


func is_player_above(body):
	return body.global_position.y < global_position.y


func boss_take_damage():
	boss_health -= 1

	if sprite:
		sprite.modulate = Color(1,0.4,0.4)
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color(1,1,1)

	if boss_health <= 0:
		boss_die()


func boss_die():
	is_dead = true

	if collision_shape:
		collision_shape.set_deferred("disabled", true)

	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "scale", Vector2(1.8,1.8), 0.3)
		tween.tween_property(sprite, "modulate:a", 0, 0.6)
		await tween.finished

	queue_free()
