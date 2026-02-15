extends CharacterBody2D

const MAX_SPEED            := 180.0
const ACCELERATION         := 900.0
const FRICTION             := 1400.0
const AIR_CONTROL          := 0.65
const JUMP_VELOCITY        := -320.0
const GRAVITY_SCALE        := 1.0
const DASH_SPEED           := 420.0
const DASH_GRAVITY_SCALE   := 0.15
const DASH_DISTANCE        := 300.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var is_attacking: bool = false
var is_dashing: bool = false
var dash_direction: int
var dash_target_x: float

func _ready():
	anim.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		var effective_gravity = gravity * GRAVITY_SCALE
		if is_dashing:
			effective_gravity *= DASH_GRAVITY_SCALE
		velocity.y += effective_gravity * delta

	if can_act():
		if Input.is_action_just_pressed("attack"):
			perform_attack("melee_attack")
		elif Input.is_action_just_pressed("heavy_attack"):
			perform_attack("heavy_attack")
		elif Input.is_action_just_pressed("dash"):
			perform_dash()

	if can_act():
		handle_movement(delta)
		update_animations()

	move_and_slide()

	if is_dashing:
		if is_on_wall() or (dash_direction > 0 and global_position.x >= dash_target_x) or (dash_direction < 0 and global_position.x <= dash_target_x):
			end_dash()

func can_act() -> bool:
	return not is_attacking and not is_dashing

func handle_movement(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		# Optional: horizontal boost if moving
		var direction = Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x = direction * MAX_SPEED  # instant max speed in jump direction

	var direction := Input.get_axis("move_left", "move_right")
	var target_speed = direction * MAX_SPEED
	var acceleration = ACCELERATION if is_on_floor() else ACCELERATION * AIR_CONTROL

	if direction:
		velocity.x = move_toward(velocity.x, target_speed, acceleration * delta)
		anim.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

func update_animations() -> void:
	if is_on_floor():
		if abs(velocity.x) > 10.0:
			anim.play("walk")
		else:
			anim.play("idle")
	else:
		anim.play("jump")

func perform_attack(attack_name: String) -> void:
	is_attacking = true
	velocity.x = 0
	anim.play(attack_name)
	await anim.animation_finished
	is_attacking = false
	anim.play("idle")

func perform_dash() -> void:
	is_dashing = true
	dash_direction = -1 if anim.flip_h else 1
	dash_target_x = global_position.x + dash_direction * DASH_DISTANCE
	velocity.x = dash_direction * DASH_SPEED
	velocity.y = 0
	anim.play("dash")

func _on_animation_finished():
	if is_dashing and anim.animation == "dash":
		end_dash()

func end_dash():
	if not is_dashing:
		return
	is_dashing = false
	velocity.x = move_toward(velocity.x, 0.0, DASH_SPEED * 0.5)
	if is_on_floor():
		anim.play("stop")
