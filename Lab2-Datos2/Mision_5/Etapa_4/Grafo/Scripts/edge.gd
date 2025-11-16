extends Line2D

@export var from_node: Node2D
@export var to_node: Node2D
@export var capacity: int = 10
@export var flow: int = 0

@onready var label: Label = $Label

func _ready():
	update_edge()

func update_edge():
	if from_node and to_node:
		points = [from_node.position, to_node.position]
		label.position = (from_node.position + to_node.position) / 2 - position
		label.text = str(flow) + "/" + str(capacity)
		
		# Cambia el color según el flujo
		if flow >= capacity:
			default_color = Color(1, 0, 0) # rojo (lleno)
		elif flow > 0:
			default_color = Color(1, 1, 0) # amarillo (usado)
		else:
			default_color = Color(0, 1, 0) # verde (libre)
		
		# Cambia el grosor según el flujo
		width = 3 + (flow * 0.5)

# 🔒 Saber si una arista está llena
func is_full() -> bool:
	return flow >= capacity

func highlight():
	default_color = Color(1,0,1)
	update_edge()
