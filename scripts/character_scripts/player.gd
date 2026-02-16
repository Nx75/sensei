extends CharacterBody2D

## --- Configuration ---
const MAX_SPEED           := 180.0
const ACCELERATION        := 900.0
const FRICTION            := 1400.0
const AIR_CONTROL         := 0.65
const JUMP_VELOCITY       := -320.0
const DASH_SPEED          := 420.0
const DASH_DISTANCE       := 300.0

## --- State Variables ---
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_attacking: bool = false
var is_dashing: bool = false
var dash_direction: int = 0
var dash_start_x: float = 0.0

## --- Node References ---
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var idle_collision: CollisionShape2D = $idle
@onready var jump_collision: CollisionShape2D = $jump

func _ready() -> void:
	# Ensure correct initial collision state
	_update_collision_shape()

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	
	if can_act():
		handle_input(delta)
	
	move_and_slide()
	
	# Logic updates
	_update_collision_shape()
	_update_animations()
	_check_dash_completion()

## --- Core Logic ---

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		# Reduce gravity significantly during dash for a "hover" effect
		var multiplier = 0.15 if is_dashing else 1.0
		velocity.y += gravity * multiplier * delta

func handle_input(delta: float) -> void:
	# Combat/Actions
	if Input.is_action_just_pressed("attack"):
		_perform_attack("melee_attack")
		return
	if Input.is_action_just_pressed("heavy_attack"):
		_perform_attack("heavy_attack")
		return
	if Input.is_action_just_pressed("dash"):
		_perform_dash()
		return

	# Movement
	var direction := Input.get_axis("move_left", "move_right")
	
	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Horizontal Physics
	var target_speed = direction * MAX_SPEED
	var accel_rate = ACCELERATION if is_on_floor() else ACCELERATION * AIR_CONTROL
	
	if direction != 0:
		velocity.x = move_toward(velocity.x, target_speed, accel_rate * delta)
		anim.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

## --- Collision & State Management ---

func _update_collision_shape() -> void:
	# Switch shapes based on whether we are airborne
	if is_on_floor():
		idle_collision.disabled = false
		jump_collision.disabled = true
	else:
		idle_collision.disabled = true
		jump_collision.disabled = false

func can_act() -> bool:
	return not is_attacking and not is_dashing

## --- Action Methods ---

func _perform_attack(attack_name: String) -> void:
	is_attacking = true
	velocity.x = 0 # Stop movement during attack
	anim.play(attack_name)
	await anim.animation_finished
	is_attacking = false

func _perform_dash() -> void:
	is_dashing = true
	dash_direction = -1 if anim.flip_h else 1
	dash_start_x = global_position.x
	velocity.x = dash_direction * DASH_SPEED
	velocity.y = 0 
	anim.play("dash")

func _check_dash_completion() -> void:
	if not is_dashing: return
	
	var distance_traveled = abs(global_position.x - dash_start_x)
	
	if is_on_wall() or distance_traveled >= DASH_DISTANCE:
		is_dashing = false
		# Optional: slight slide after dash
		velocity.x = move_toward(velocity.x, 0, DASH_SPEED * 0.5)

func _update_animations() -> void:
	if is_attacking or is_dashing:
		return
		
	if is_on_floor():
		if abs(velocity.x) > 10.0:
			anim.play("walk")
		else:
			anim.play("idle")
	else:
		anim.play("jump")
