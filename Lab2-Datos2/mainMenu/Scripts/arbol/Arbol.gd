# ArbolBinario.gd
class_name ArbolBinario
extends Node

var raiz: Nodo = null

# Agregar un nuevo nodo al árbol
func agregar_nodo(dato: Dictionary) -> void:
	var nuevo_nodo = Nodo.new(dato)
	if raiz == null:
		raiz = nuevo_nodo
		
	else:
		agregar_recursivo(raiz, nuevo_nodo)

# Función recursiva para insertar el nodo
func agregar_recursivo(nodo: Nodo, nuevo_nodo: Nodo) -> void:
	if not ("valor" in nuevo_nodo.dato) or not ("valor" in nodo.dato):
		push_error("El nodo no contiene la clave 'valor'")
		return

	if nuevo_nodo.dato["valor"] < nodo.dato["valor"]:
		if nodo.izq == null:
			nodo.izq = nuevo_nodo
		else:
			agregar_recursivo(nodo.izq, nuevo_nodo)
	else:
		if nodo.der == null:
			nodo.der = nuevo_nodo
		else:
			agregar_recursivo(nodo.der, nuevo_nodo)
func buscar_subarbol(valor: int) -> Nodo:
	return _buscar_recursivo(raiz, valor)

func _buscar_recursivo(nodo2: Nodo, valor: int) -> Nodo:
	if nodo2 == null:
		
		return null

	var actual_valor = nodo2.dato.get("valor", null)
	if actual_valor == null:
		return null

	if valor == actual_valor:
		return nodo2
	elif valor < actual_valor:
		return _buscar_recursivo(nodo2.izq, valor)
	else:
		return _buscar_recursivo(nodo2.der, valor)
func cambiar_estado(valor: int, nuevo_bool: bool) -> bool:
	var nodo = buscar_subarbol(valor)
	if nodo == null:
		return false  

	nodo.dato["activado"] = nuevo_bool
	return true 
