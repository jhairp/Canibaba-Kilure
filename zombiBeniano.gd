extends CharacterBody2D

@export var speed := 40.0
@export var max_health := 3
@onready var anim := $AnimatedSprite2D

signal zombie_killed  # señal al morir

var target: Node2D = null
var is_hurt := false
var is_attacking := false
var health := max_health

func _ready():
	anim.play("walk")

func _physics_process(delta):
	if is_hurt:
		return
	if target:
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		anim.flip_h = direction.x < 0

		if global_position.distance_to(target.global_position) < 55 and not is_attacking:
			_attack()
		else:
			if not is_attacking and anim.animation != "walk":
				anim.play("walk")
	else:
		velocity = Vector2.ZERO
		move_and_slide()
		if anim.animation != "idle":
			anim.play("idle")

func _attack():
	is_attacking = true
	anim.play("attack")
	velocity = Vector2.ZERO
	await anim.animation_finished
	is_attacking = false
	anim.play("walk")

func take_damage(from_position: Vector2):
	if is_hurt:
		return
	is_hurt = true
	health -= 1
	anim.play("hurt")

	var knock_dir = (global_position - from_position).normalized()
	position += knock_dir * 15

	for i in range(3):
		modulate = Color(1, 1, 1, 0.3)
		await get_tree().create_timer(0.1).timeout
		modulate = Color(1, 1, 1, 1)
		await get_tree().create_timer(0.1).timeout

	is_hurt = false

	if health <= 0:
		_die()
	else:
		anim.play("walk")

func _die():
	print("💀 Zombi eliminado:", name)

	# Avisar al nivel que el zombi murió
	var parent_scene = get_tree().current_scene
	if parent_scene.has_method("_on_zombie_killed"):
		parent_scene._on_zombie_killed()

	# Parpadeo corto antes de desaparecer
	modulate = Color(1, 1, 1, 0.2)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1, 1)

	queue_free()
