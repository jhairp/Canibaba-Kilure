extends CharacterBody2D

@export var speed := 150.0
@onready var anim := $AnimatedSprite2D

var is_attacking: bool = false
var is_hurt: bool = false

func _ready():
	anim.play("idle")

func _physics_process(delta):
	# Vector de movimiento
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	# Movimiento base
	velocity = input_vector * speed
	move_and_slide()

	# --- Animaciones de movimiento ---
	if is_attacking:
		return  # deja que la animación de ataque se complete
	elif input_vector == Vector2.ZERO:
		if anim.animation != "idle":
			anim.play("idle")
	else:
		if anim.animation != "walk":
			anim.play("walk")

	# --- Dirección ---
	if input_vector.x < 0:
		anim.flip_h = true
	elif input_vector.x > 0:
		anim.flip_h = false

	# --- Ataque con Z ---
	if Input.is_action_just_pressed("attack_z") and not is_attacking:
		_attack()

func _attack():
	is_attacking = true
	anim.play("attack")
	await anim.animation_finished
	is_attacking = false

	# Si sigue moviéndose, volver a caminar, si no, quedarse quieto
	if velocity.length() > 0:
		anim.play("walk")
	else:
		anim.play("idle")
