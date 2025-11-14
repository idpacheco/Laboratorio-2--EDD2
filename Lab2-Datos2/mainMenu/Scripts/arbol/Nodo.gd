# nodo.gd
class_name Nodo

var dato: Dictionary
var der: Nodo = null
var izq: Nodo = null

func _init(dato2: Dictionary) -> void:
	dato = dato2
	der = null
	izq = null

# Getters
func get_dato() -> Dictionary:
	return dato

func get_der() -> Nodo:
	return der

func get_izq() -> Nodo:
	return izq

# Setters
func set_dato(nuevo_dato: Dictionary) -> void:
	dato = nuevo_dato

func set_der(nuevo_der: Nodo) -> void:
	der = nuevo_der

func set_izq(nuevo_izq: Nodo) -> void:
	izq = nuevo_izq
