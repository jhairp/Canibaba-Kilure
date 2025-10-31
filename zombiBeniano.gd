extends CharacterBody2D

@export var speed := 40.0
@export var max_health := 3  # número de golpes que puede recibir
@onready var anim := $AnimatedSprite2D

var target: Node2D = null
var is_hurt := false
var is_attacking := false
var health := max_health


# =========================================================
# CONFIGURACIÓN INICIAL
# =========================================================
func _ready():
	anim.play("walk")


# =========================================================
# PROCESO PRINCIPAL
# =========================================================
func _physics_process(delta):
	if is_hurt:
		return  # no moverse ni animar si está herido
	
	if target:
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

		# --- Girar sprite ---
		anim.flip_h = direction.x < 0

		# --- Si está cerca, atacar ---
		if global_position.distance_to(target.global_position) < 55 and not is_attacking:
			_attack()
		else:
			# reproducir "walk" solo si no está atacando
			if not is_attacking and anim.animation != "walk":
				anim.play("walk")
	else:
		velocity = Vector2.ZERO
		move_and_slide()
		if anim.animation != "idle":
			anim.play("idle")


# =========================================================
# ATAQUE
# =========================================================
func _attack():
	is_attacking = true
	anim.play("attack")
	velocity = Vector2.ZERO
	await anim.animation_finished
	is_attacking = false
	anim.play("walk")


# =========================================================
# DAÑO Y MUERTE SIMPLE
# =========================================================
func take_damage(from_position: Vector2):
	if is_hurt:
		return
	is_hurt = true
	health -= 1
	anim.play("hurt")

	# Retroceso (knockback)
	var knock_dir = (global_position - from_position).normalized()
	position += knock_dir * 15

	# Parpadeo visual
	for i in range(3):
		modulate = Color(1, 1, 1, 0.3)
		await get_tree().create_timer(0.1).timeout
		modulate = Color(1, 1, 1, 1)
		await get_tree().create_timer(0.1).timeout

	is_hurt = false

	# Si la vida llega a 0, eliminar zombi
	if health <= 0:
		_die()
	else:
		anim.play("walk")


# =========================================================
# DESAPARICIÓN SIMPLE (SIN ANIMACIÓN)
# =========================================================
func _die():
	print("💀 Zombi eliminado:", name)

	# Un solo parpadeo corto
	modulate = Color(1, 1, 1, 0.2)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1, 1)

	queue_free()
