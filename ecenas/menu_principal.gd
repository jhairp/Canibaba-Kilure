extends Control

# No pongas conexiones manuales aquí
func _ready():
	pass

func _on_boton_jugar_pressed():
	print("✅ Botón jugar presionado")
	get_tree().change_scene_to_file("res://ecenas/Ecenas/historia.tscn")

func _on_boton_salir_pressed():
	get_tree().quit()
