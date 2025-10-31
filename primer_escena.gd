extends Node2D

func _ready():
	var player = $PersonajeLuis  # 👈 exactamente igual al nombre del nodo
	for zombie in get_tree().get_nodes_in_group("zombies"):
		zombie.target = player
