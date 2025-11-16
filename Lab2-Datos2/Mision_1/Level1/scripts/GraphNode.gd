extends Node2D

@export var node_id: String = ""          # A, B, C...
@export var server_name: String = ""      # Base de Datos, Firewall, etc.
@export var compromised: bool = false     # Si está comprometido

@onready var icon = $Icon
@onready var label = $Label

func _ready():
	# Muestra la letra del nodo
	label.text = node_id

	# Estado inicial
	reset()


# ---------------------------------------------------------
# Marca el nodo como visitado (verde)
# ---------------------------------------------------------
func mark_visited():
	icon.modulate = Color(0.2, 1.0, 0.2)  # Verde brillante
	label.modulate = Color.WHITE


# ---------------------------------------------------------
# Restablece al estado normal
# ---------------------------------------------------------
func reset():
	if compromised:
		icon.modulate = Color(1.0, 0.2, 0.2) # Rojo si está comprometido
	else:
		icon.modulate = Color(1, 1, 1)        # Blanco normal

	label.modulate = Color(0.1, 0.1, 0.1)


# ---------------------------------------------------------
# Efecto hover opcional (si lo quieres)
# ---------------------------------------------------------
func highlight():
	icon.modulate = Color.YELLOW

func unhighlight():
	reset()
