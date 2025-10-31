extends Node2D

@onready var player := $PersonajeLuis
@onready var spawner := $SpawnerZombies
@onready var musica := $MusicaFondo

var zombies_killed := 0
var exiting := false

func _ready():
	print("🌲 Nivel iniciado: Luis entra automáticamente.")
	player.start_auto_move(Vector2.RIGHT, 150.0)
	await get_tree().create_timer(3.0).timeout
	player.stop_auto_move()
	print("🎮 Control del jugador activado.")

	# --- Música de fondo ---
	var stream = load("res://assets/Music/musica/fondo-bosque.ogg")
	stream.loop = true
	musica.stream = stream
	musica.volume_db = -6
	musica.play()
	print("🎵 Música del bosque iniciada.")
	

func _on_zombie_killed():
	zombies_killed += 1
	print("💀 Zombis eliminados:", zombies_killed)

	if zombies_killed >= 10 and not exiting:
		exiting = true
		print("➡️ Nivel completado: saliendo...")

		player.start_auto_move(Vector2.RIGHT, 200.0)
		await get_tree().create_timer(3.5).timeout

		var next_scene = "res://ecenas/Ecenas/segunda_ecena.tscn"
		if ResourceLoader.exists(next_scene):
			print("✅ Cargando siguiente nivel...")
			get_tree().change_scene_to_file(next_scene)
		else:
			push_warning("⚠️ No se encontró la escena: " + next_scene)
