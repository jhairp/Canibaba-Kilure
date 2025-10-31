extends Node2D

@onready var player := $PersonajeLuis

@onready var musica := $MusicaFondo

func _ready():
	print(" Segundo nivel iniciado — Luis entra automáticamente.")

	# Comienza fuera del borde izquierdo de la cámara
	player.global_position.x -= 300
	player.global_position.y += 0  # ajusta si necesitas moverlo verticalmente

	# Movimiento automático hacia la derecha
	player.start_auto_move(Vector2.RIGHT, 120.0)

	# Esperar unos segundos para que entre caminando
	await get_tree().create_timer(3.0).timeout

	# Detener movimiento y devolver control al jugador
	player.stop_auto_move()
	print("🎮 Control del jugador activado en el segundo nivel.")
	

	# --- Música de fondo ---
	var stream = load("res://assets/Music/musica/musica-final-del-juego.ogg")
	stream.loop = true
	musica.stream = stream
	musica.volume_db = -6
	musica.play()
	print("🎵 Música del bosque iniciada.")
