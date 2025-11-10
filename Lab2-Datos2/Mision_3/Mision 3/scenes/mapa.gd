extends Node2D

var estaciones: Array = []
var conexiones_posibles: Array = []
var conexiones_jugador: Array = []
var grafo: Dictionary = {}
var seleccionando: bool = false
var seleccion_1: int = -1
var prim = preload("res://Prim.gd").new()

func _ready():
	preparar_estaciones_y_conexiones()
	$"../UI/BotonConectar".pressed.connect(_on_BotonConectar_pressed)
	$"../UI/BotonConfirmar".pressed.connect(_on_BotonConfirmar_pressed)
	#$UI/BotonVerOptima.pressed.connect(_on_BotonVerOptima_pressed)

func preparar_estaciones_y_conexiones():
	var ancho_pantalla = 640
	var alto_pantalla = 360
	var cantidad_estaciones:int = 6 + RandomNumberGenerator.new().randi_range(0, 4)
	var centro = Vector2(ancho_pantalla / 2, alto_pantalla / 2)
	var radio = min(ancho_pantalla, alto_pantalla) / 2 - 40 # margen para evitar el borde

	# Limpia estaciones y conexiones visuales previas
	for child in $EstacionContainer.get_children():
		$EstacionContainer.remove_child(child)
		child.queue_free()
	for child in $ConexionContainer.get_children():
		$ConexionContainer.remove_child(child)
		child.queue_free()
	estaciones.clear()
	conexiones_posibles.clear()
	conexiones_jugador.clear()
	grafo.clear()

	# Distribuye nodos en círculo
	for i in range(cantidad_estaciones):
		var angulo = TAU * float(i) / float(cantidad_estaciones)
		var pos = centro + Vector2(cos(angulo), sin(angulo)) * radio
		var esta = preload("res://scenes/estacion.tscn").instantiate()
		esta.nombre = "Estacion_%d" % i
		esta.posicion = pos
		$EstacionContainer.add_child(esta)
		estaciones.append(esta)
		esta.input_event.connect(_on_estacion_input.bind(i))
	
	# --- RESALTAR NODO INICIAL ---
	var idx_inicial = 0 # Puedes cambiar si el inicial varía
	estaciones[idx_inicial].modulate = Color.BLUE

	var rng = RandomNumberGenerator.new()
	rng.randomize()

# Genera el grafo de conexiones posibles (usando Prim para el MST y agregando extras)
	var todas_aristas = []
	for i in range(cantidad_estaciones):
		for j in range(i+1, cantidad_estaciones):
			var peso = rng.randi_range(1, 999)
			todas_aristas.append({"origen": i, "destino": j, "costo": peso})


	grafo = {}
	for i in range(cantidad_estaciones):
		grafo["Estacion_%d" % i] = []
	for a in todas_aristas:
		var o = "Estacion_%d" % a["origen"]
		var d = "Estacion_%d" % a["destino"]
		var cost = a["costo"]
		grafo[o].append([d, cost])
		grafo[d].append([o, cost])

	var prim_result = prim.prim(grafo, "Estacion_0")
	var aristas_seleccionadas = []
	for conn in prim_result:
		var idx_origen = int(conn[0].split("_")[1])
		var idx_destino = int(conn[1].split("_")[1])
		aristas_seleccionadas.append({"origen": idx_origen, "destino": idx_destino, "costo": conn[2]})

# Declarar las variables que vas a usar:
	var extra = rng.randi_range(1, cantidad_estaciones)
	var usadas = {}
	for a in aristas_seleccionadas:
		usadas["%d-%d" % [a["origen"], a["destino"]]] = true
		usadas["%d-%d" % [a["destino"], a["origen"]]] = true

	var intentos = 0
	while extra > 0 and intentos < 30:
		var u = rng.randi_range(0, cantidad_estaciones-1)
		var v = rng.randi_range(0, cantidad_estaciones-1)
		if u != v and not usadas.has("%d-%d" % [u, v]):
			var peso = rng.randi_range(1, 999)
			aristas_seleccionadas.append({"origen": u, "destino": v, "costo": peso})
			usadas["%d-%d" % [u, v]] = true
			usadas["%d-%d" % [v, u]] = true
			extra -= 1
	intentos += 1

	# Dibuja las conexiones visuales existentes
	for a in aristas_seleccionadas:
		var conn = preload("res://scenes/conexion.tscn").instantiate()
		conn.inicializar(estaciones[a["origen"]], estaciones[a["destino"]], a["costo"])
		conn.modulate = Color(0.8,0.8,0.8,0.5)
		$ConexionContainer.add_child(conn)
		conexiones_posibles.append(conn)
# --- INTERACCION DEL JUGADOR

func _on_estacion_input(viewport, event: InputEvent, shape_idx: int, idx_estacion: int):
	if seleccionando and event is InputEventMouseButton and event.pressed:
		if seleccion_1 == -1:
			seleccion_1 = idx_estacion
			estaciones[idx_estacion].modulate = Color.GREEN
		else:
			conectar_estaciones(seleccion_1, idx_estacion)
			estaciones[seleccion_1].modulate = Color.WHITE
			seleccion_1 = -1

func _on_BotonConectar_pressed():
	seleccionando = true
	seleccion_1 = -1
	for esta in estaciones:
		esta.modulate = Color.WHITE

# --- NUEVA VERSION SOLO PERMITE SI ES CONEXION VALIDA DISPONIBLE ---
func conectar_estaciones(origen_idx: int, destino_idx: int):
	var esta_origen = estaciones[origen_idx]
	var esta_destino = estaciones[destino_idx]
	var conexion_visual_existente := false
	for conn in conexiones_posibles:
		if (conn.origen == esta_origen and conn.destino == esta_destino) \
		or (conn.origen == esta_destino and conn.destino == esta_origen):
			conexion_visual_existente = true
			break
	if not conexion_visual_existente:
		# Feedback visual de que no se puede
		esta_origen.modulate = Color(1,0.6,0.2) # naranja
		esta_destino.modulate = Color(1,0.6,0.2)
		return

	# ... AHORA SÍ continúa con la lógica original:
	var costo = obtener_costo(origen_idx, destino_idx)
	if costo == INF:
		return
	if not _generaria_ciclo(origen_idx, destino_idx):
		var conexion = preload("res://scenes/conexion.tscn").instantiate()
		conexion.inicializar(esta_origen, esta_destino, costo)
		conexion.modulate = Color.YELLOW
		$ConexionContainer.add_child(conexion)
		conexiones_jugador.append(conexion)
		mostrar_costo()
	else:
		esta_origen.modulate = Color.RED
		esta_destino.modulate = Color.RED

func obtener_costo(origen_idx: int, destino_idx: int) -> float:
	var n_origen = estaciones[origen_idx].nombre
	var n_destino = estaciones[destino_idx].nombre
	for dato in grafo[n_origen]:
		if dato[0] == n_destino:
			return dato[1]
	return INF

func calcular_costo_jugador() -> float:
	var total = 0.0
	for conexion in conexiones_jugador:
		total += conexion.costo
	return total

func mostrar_costo():
	$"../UI/CostoLabel".text = "Tu costo: %d" % calcular_costo_jugador()

func _on_BotonConfirmar_pressed():
	var costo_player = calcular_costo_jugador()
	$"../UI/CostoLabel".text = "Tu costo: %d" % costo_player
	var mst = prim.prim(grafo, "Estacion_0")
	var costo_optimo = 0.0
	for conn in mst:
		costo_optimo += conn[2]
	$"../UI/OptimoLabel".text = "Costo óptimo: %d (Prim)" % costo_optimo
	_resaltar_mst(mst)


func _on_BotonVerOptima_pressed():
	var mst = prim.prim(grafo, "Estacion_0")
	_resaltar_mst(mst)

func _resaltar_mst(mst: Array):
	for conn in $ConexionContainer.get_children():
		conn.modulate = Color(0.8, 0.8, 0.8, 0.5)
	for conn in mst:
		var idx_origen = int(conn[0].split("_")[1])
		var idx_destino = int(conn[1].split("_")[1])
		for child in $ConexionContainer.get_children():
			if (child.origen == estaciones[idx_origen] and child.destino == estaciones[idx_destino]) or \
			   (child.origen == estaciones[idx_destino] and child.destino == estaciones[idx_origen]):
				child.modulate = Color.BLUE

# --- Ciclo: union-find helpers ---
func _generaria_ciclo(origen_idx: int, destino_idx: int) -> bool:
	var parent: Array = []
	for i in range(estaciones.size()):
		parent.append(i)
	for i in range(estaciones.size()):
		parent[i] = i

	for conn in conexiones_jugador:
		var idx1 = estaciones.find(conn.origen)
		var idx2 = estaciones.find(conn.destino)
		union(parent, idx1, idx2)
	if find(parent, origen_idx) == find(parent, destino_idx):
		return true
	union(parent, origen_idx, destino_idx)
	return false

func find(parent: Array, x: int) -> int:
	while parent[x] != x:
		x = parent[x]
	return x

func union(parent: Array, x: int, y: int):
	parent[find(parent, x)] = find(parent, y)
