extends CharacterBody2D

@export var speed := 150.0
@onready var anim := $SpritePivot/AnimatedSprite2D
@onready var pivot := $SpritePivot
@onready var collision := $CollisionShape2D

# --- Sonidos ---
@onready var sfx_machete_aire: AudioStreamPlayer2D = $SFX_MacheteAire
@onready var sfx_machete_corte: AudioStreamPlayer2D = $SFX_MacheteCorte
@onready var sfx_pasos: AudioStreamPlayer2D = $SFX_Pasos

# --- Estados ---
var is_attacking := false
var is_hurt := false
var input_vector := Vector2.ZERO
var control_enabled := true
var auto_move_dir := Vector2.ZERO
var auto_move_speed := 0.0

func _ready():
	print("🔊 Personaje cargado correctamente. Probando sonidos...")
	if not sfx_machete_aire.stream:
		push_warning("⚠️ Falta asignar machete-al-aire.wav en SFX_MacheteAire")
	if not sfx_machete_corte.stream:
		push_warning("⚠️ Falta asignar machete-cortando.wav en SFX_MacheteCorte")
	if not sfx_pasos.stream:
		push_warning("⚠️ Falta asignar pasos-en-tierra.wav en SFX_Pasos")

# =========================================================
# PROCESO PRINCIPAL
# =========================================================
func _physics_process(delta):
	if auto_move_dir != Vector2.ZERO:
		velocity = auto_move_dir * auto_move_speed
		move_and_collide(velocity * delta)
		anim.play("walk")
		return

	if not control_enabled or is_attacking or is_hurt:
		move_and_slide()
		return

	input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()

	velocity = input_vector * speed
	move_and_slide()

	# --- Animaciones y pasos ---
	if input_vector == Vector2.ZERO:
		anim.play("idle")
		if sfx_pasos.playing:
			sfx_pasos.stop()
	else:
		anim.play("walk")
		if not sfx_pasos.playing:
			sfx_pasos.play()

	# --- Dirección ---
	if input_vector.x < 0:
		pivot.scale.x = -1
	elif input_vector.x > 0:
		pivot.scale.x = 1

	# --- Ataque ---
	if Input.is_action_just_pressed("attack_z") and not is_attacking:
		_attack()


# =========================================================
# ATAQUE
# =========================================================
func _attack():
	is_attacking = true
	anim.play("attack")

	if sfx_machete_aire:
		sfx_machete_aire.play()

	var hit_detected = false
	for zombie in get_tree().get_nodes_in_group("zombies"):
		var dist = global_position.distance_to(zombie.global_position)
		if dist < 140:
			zombie.take_damage(global_position)
			hit_detected = true

	if hit_detected and sfx_machete_corte:
		sfx_machete_corte.play()

	await anim.animation_finished
	is_attacking = false

	if velocity.length() > 0.1:
		anim.play("walk")
	else:
		anim.play("idle")


# =========================================================
# MOVIMIENTO AUTOMÁTICO
# =========================================================
func start_auto_move(direction: Vector2, speed_value: float):
	auto_move_dir = direction.normalized()
	auto_move_speed = speed_value
	collision.disabled = true
	control_enabled = false
	anim.play("walk")
	if sfx_pasos.playing:
		sfx_pasos.stop()
	print("🤖 Movimiento automático activado.")


func stop_auto_move():
	auto_move_dir = Vector2.ZERO
	auto_move_speed = 0.0
	collision.disabled = false
	control_enabled = true
	anim.play("idle")
	print("🎮 Movimiento automático detenido.")
