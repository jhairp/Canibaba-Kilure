extends CharacterBody2D

@export var speed := 150.0
@onready var anim := $SpritePivot/AnimatedSprite2D
@onready var pivot := $SpritePivot

var is_attacking := false
var is_hurt := false
var input_vector := Vector2.ZERO

func _physics_process(delta):
	if is_attacking or is_hurt:
		move_and_slide()
		return

	input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()

	velocity = input_vector * speed
	move_and_slide()

	# --- Animaciones ---
	if input_vector == Vector2.ZERO:
		anim.play("idle")
	else:
		anim.play("walk")

	# --- Dirección horizontal (flip sin saltos) ---
	if input_vector.x < 0:
		pivot.scale.x = -1
	elif input_vector.x > 0:
		pivot.scale.x = 1

	# --- Ataque con Z ---
	if Input.is_action_just_pressed("attack_z") and not is_attacking:
		_attack()


func _attack():
	is_attacking = true
	anim.play("attack")

	# Detectar zombies cercanos
	for zombie in get_tree().get_nodes_in_group("zombies"):
		var dist = global_position.distance_to(zombie.global_position)
		if dist < 140:
			print("Golpe detectado en", zombie.name)
			zombie.take_damage(global_position)

	await anim.animation_finished
	is_attacking = false

	if velocity.length() > 0.1:
		anim.play("walk")
	else:
		anim.play("idle")
