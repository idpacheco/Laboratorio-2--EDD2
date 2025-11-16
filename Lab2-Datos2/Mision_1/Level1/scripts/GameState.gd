extends Node

# Lista de TODOS los nodos del grafo (A, B, C, D, E, F...)
var all_nodes: Array = []

# Lista real de nodos infectados aleatoriamente
var compromised: Array = []

# Recorrido BFS final
var bfs_order: Array = []

# Recorrido DFS final
var dfs_order: Array = []

# Para resetear si cambias de escena
func reset():
	all_nodes.clear()
	compromised.clear()
	bfs_order.clear()
	dfs_order.clear()

func has_both_traversals() -> bool:
	return bfs_order.size() > 0 and dfs_order.size() > 0
