extends CharacterBody2D

@export var speed := 40.0
@onready var anim := $AnimatedSprite2D

var target: Node2D = null
var is_hurt: bool = false
var is_attacking: bool = false

func _physics_process(delta):
	if is_hurt:
		return  # no moverse mientras recibe daño
	
	if target and not is_attacking:
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		
		# Animación de caminar
		if anim.animation != "walk":
			anim.play("walk")

		# Girar sprite según dirección
		anim.flip_h = direction.x < 0

		# Si está cerca del jugador, atacar
		if global_position.distance_to(target.global_position) < 25:
			_attack()
	else:
		velocity = Vector2.ZERO
		move_and_slide()
		if anim.animation != "idle" and not is_attacking:
			anim.play("idle")

func _attack():
	if is_attacking:
		return
	is_attacking = true
	anim.play("attack")
	velocity = Vector2.ZERO
	await anim.animation_finished
	is_attacking = false

func take_damage(from_position: Vector2):
	if is_hurt:
		return
	is_hurt = true
	anim.play("hurt")

	# Retroceso (knockback)
	var knock_dir = (global_position - from_position).normalized()
	position += knock_dir * 8

	# Parpadeo simple
	for i in range(4):
		modulate = Color(1, 1, 1, 0.3)
		await get_tree().create_timer(0.1).timeout
		modulate = Color(1, 1, 1, 1)
		await get_tree().create_timer(0.1).timeout

	is_hurt = false
	anim.play("walk")
