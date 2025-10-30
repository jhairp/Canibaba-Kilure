extends CharacterBody2D

@export var speed := 150.0
@onready var anim := $AnimatedSprite2D

var is_attacking := false
var is_hurt := false

func _ready():
	anim.play("acciones")  # Aseguramos que esté activa
	anim.stop()             # Comienza quieto en frame 0
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

	# Estado quieto o caminando
	if input_vector == Vector2.ZERO:
		anim.frame = 0  # quieto
	else:
		# alterna entre frame 1 y 2 (caminar)
		anim.play("acciones")
		if anim.frame < 1 or anim.frame > 2:
			anim.frame = 1
		anim.speed_scale = 6.0

	# Voltear sprite según dirección
	if input_vector.x < 0:
		anim.flip_h = true
	elif input_vector.x > 0:
		anim.flip_h = false

	# Acciones especiales
	if Input.is_action_just_pressed("attack"):
		_attack()
	elif Input.is_action_just_pressed("hurt"):
		_take_damage()


func _attack():
	is_attacking = true
	anim.stop()
	anim.frame = 4  # atacar
	await get_tree().create_timer(0.4).timeout
	is_attacking = false
	anim.frame = 0

func _take_damage():
	is_hurt = true
	anim.stop()
	anim.frame = 3  # recibir daño
	await get_tree().create_timer(0.5).timeout
	is_hurt = false
	anim.frame = 0
