extends Node

func prim(grafo: Dictionary, nodo_inicial: String) -> Array:
	var mst = []
	var visitados = [nodo_inicial]
	var candidatos = []

	for dest_costo in grafo[nodo_inicial]:
		candidatos.append([nodo_inicial, dest_costo[0], dest_costo[1]])

	while visitados.size() < grafo.size():
		var min_costo = INF
		var seleccion = null
		for c in candidatos:
			if !(c[1] in visitados) and c[2] < min_costo:
				min_costo = c[2]
				seleccion = c
		if seleccion:
			mst.append(seleccion)
			visitados.append(seleccion[1])
			for dest_costo in grafo[seleccion[1]]:
				if !(dest_costo[0] in visitados):
					candidatos.append([seleccion[1], dest_costo[0], dest_costo[1]])
			var nuevos_candidatos = []
			for x in candidatos:
				if !(x[1] in visitados):
					nuevos_candidatos.append(x)
			candidatos = nuevos_candidatos
	return mst
