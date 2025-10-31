extends Control

@onready var fondo := $His1        # Tu Sprite2D
@onready var texto := $LabelTexto
@onready var boton := $BotonContinuar

# 📜 Tres partes de historia (texto e imagen)
var escenas = [
	{
		"imagen": "res://assets/images/his1.png",
		"texto": """
Hace mucho tiempo, en una tierra olvidada, una Bolivia post apocalíptica, dominada por almas
malditas, poseídas por un ente maligno, existían dos hermanos, Luis y Juan, quienes a pesar de 
no tener mucho y sobrevivir cada día, se las ingeniaban para vivir cómodamente.
"""
	},
	{
		"imagen": "res://assets/images/his2.png",
		"texto": """
Hasta que un día, Juan encontró un perrito que parecía lastimado.En su inocencia, decidió seguirlo,
 sin saber que detrás de aquel animal estaba aquel ente responsable del dolor de muchas personas: 
el mismísimo Canibaba Kilure, esperando pacientemente para disfrutar otra de sus víctimas.
"""
	},
	{
		"imagen": "res://assets/images/his3.png",
		"texto": """
Luis, al ver que su hermano había desaparecido, entró en un miedo agonizante. Por la desesperación, 
dejó su refugio y se llevó lo poco que tenía. Con un machete en mano, decidió ir en busca 
de su mejor amigo, su pequeño hermano, aun sabiendo que se enfrentaría a cientos de almas malditas. 
Aun así, Luis decidió ir... sin darse cuenta de que aquellos ojos del bosque ya lo estaban observando.
"""
	}
]

var indice := 0
var escribiendo := false

func _ready():
	var stream = load("res://assets/Music/musica/fondo-bosque.ogg")
	var audio = AudioStreamPlayer.new()
	add_child(audio)
	audio.stream = stream
	audio.autoplay = false
	audio.volume_db = -6
	audio.play()

	boton.pressed.connect(_on_boton_continuar_pressed)
	_mostrar_historia_actual()
# 🪶 Mostrar imagen y texto con efecto máquina de escribir
func _mostrar_historia_actual():
	var escena_actual = escenas[indice]

	# Cambia la imagen (Sprite2D)
	fondo.texture = load(escena_actual["imagen"])
	fondo.scale = Vector2(0.75, 0.64)  # ajusta al tamaño que se vea bien en tu pantalla

	# Muestra el texto actual
	texto.text = escena_actual["texto"]
	texto.visible_characters = 0
	escribiendo = true
	boton.disabled = true

	var timer := Timer.new()
	timer.wait_time = 0.03
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(func():
		texto.visible_characters += 1
		if texto.visible_characters >= texto.text.length():
			timer.queue_free()
			escribiendo = false
			boton.disabled = false
	)
	timer.start()

# 👉 Avanzar entre las historias o ir al juego
func _on_boton_continuar_pressed():
	if escribiendo:
		# Si aún se escribe, muestra todo el texto al instante
		texto.visible_characters = texto.text.length()
		escribiendo = false
		boton.disabled = false
		return

	indice += 1
	if indice < escenas.size():
		_mostrar_historia_actual()
	else:
		get_tree().change_scene_to_file("res://ecenas/Ecenas/primer_ecena.tscn")
