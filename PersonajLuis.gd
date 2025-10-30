extends CharacterBody2D

@export var speed := 150.0
@onready var anim := $AnimatedSprite2D

var is_attacking := false
var is_hurt := false

func _ready():
	anim.play("acciones")
	anim.stop()
	anim.frame = 0

func _physics_process(delta):
	if is_attacking or is_hurt:
		move_and_slide()
		return
	
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	velocity = input_vector * speed
	move_and_slide()

	# --- Movimiento ---
	if input_vector == Vector2.ZERO:
		anim.stop()
		anim.frame = 0
	else:
		anim.play("acciones")
		if anim.frame < 1 or anim.frame > 2:
			anim.frame = 1
		anim.speed_scale = 2.0

	# --- Dirección ---
	if input_vector.x < 0:
		anim.flip_h = true
	elif input_vector.x > 0:
		anim.flip_h = false

	# --- Ataque con Z ---
	if Input.is_action_just_pressed("attack_z"):
		_attack()


func _attack():
	is_attacking = true
	anim.stop()
	
	# reproducir frames 3 y 4 rápidamente
	anim.frame = 3
	await get_tree().create_timer(0.12).timeout
	anim.frame = 4
	await get_tree().create_timer(0.18).timeout
	
	# volver al estado quieto
	is_attacking = false
	anim.frame = 0
