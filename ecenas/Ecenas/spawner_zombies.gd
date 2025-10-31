extends Node2D

@export var zombie_scene: PackedScene
@export var spawn_interval := 3.0
@export var max_zombies := 2               # máximo simultáneos en pantalla
@export var max_total_zombies := 10        # máximo total generados
@export var player: Node2D

var timer := Timer.new()
var total_spawned := 0                     # contador total generados
var total_killed := 0                      # contador total eliminados


func _ready():
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(_try_spawn)
	print("🧟 Spawner activo.")


# =========================================================
# INTENTO DE CREAR NUEVOS ZOMBIS
# =========================================================
func _try_spawn():
	# Si ya se generaron los 10 zombis en total, no genera más
	if total_spawned >= max_total_zombies:
		timer.stop()
		print("🧟‍♂️ Spawner detenido (10 zombis creados en total).")
		return

	var zombies = get_tree().get_nodes_in_group("zombies")
	if zombies.size() >= max_zombies:
		return

	# cantidad posible a generar sin exceder el máximo
	var cantidad = min(2, max_total_zombies - total_spawned)
	for i in range(cantidad):
		_spawn_zombie()


# =========================================================
# CREAR UN NUEVO ZOMBI
# =========================================================
func _spawn_zombie():
	if not zombie_scene or not player:
		return

	var pos = _get_spawn_position()
	if pos == Vector2.ZERO:
		return

	var zombie = zombie_scene.instantiate()
	get_parent().add_child(zombie)
	zombie.global_position = pos
	zombie.target = player
	total_spawned += 1  # suma total generados

	# Conectar señales
	if get_parent().has_method("_on_zombie_killed"):
		zombie.connect("zombie_killed", Callable(self, "_on_zombie_killed_internal"))

	print("🧟 Zombi creado en:", pos, "| Total generados:", total_spawned)


# =========================================================
# CUANDO UN ZOMBI MUERE
# =========================================================
func _on_zombie_killed_internal():
	total_killed += 1
	print("💀 Zombi muerto:", total_killed, "/", max_total_zombies)

	# Avisar a la escena principal (nivel)
	if get_parent().has_method("_on_zombie_killed"):
		get_parent()._on_zombie_killed()

	# Si ya se eliminaron todos los generados
	if total_killed >= max_total_zombies:
		print("🏁 Todos los zombis eliminados. No quedan más enemigos.")
		timer.stop()


# =========================================================
# OBTENER UNA POSICIÓN DE APARICIÓN ALEATORIA
# =========================================================
func _get_spawn_position() -> Vector2:
	var cam = get_viewport().get_camera_2d()
	if not cam:
		return Vector2.ZERO

	var rect = get_viewport_rect()
	var view_size = rect.size
	var cam_center = cam.global_position

	var sides = ["left", "right", "bottom"]  # 👈 ya no aparecen desde arriba
	var side = sides.pick_random()

	var x = 0.0
	var y = 0.0

	match side:
		"left":
			x = cam_center.x - (view_size.x / 2) - 200
			y = randf_range(cam_center.y - view_size.y / 2, cam_center.y)
		"right":
			x = cam_center.x + (view_size.x / 2) + 200
			y = randf_range(cam_center.y - view_size.y / 2, cam_center.y)
		"bottom":
			x = randf_range(cam_center.x - view_size.x / 2, cam_center.x + view_size.x / 2)
			y = cam_center.y + (view_size.y / 2) + 200

	return Vector2(x, y)
