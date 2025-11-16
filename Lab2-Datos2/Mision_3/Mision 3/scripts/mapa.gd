extends Node2D

var estaciones: Array = []
var conexiones_posibles: Array = []
var conexiones_jugador: Array = []
var grafo: Dictionary = {}
var seleccionando: bool = false
var seleccion_1: int = -1
var seleccionando_desconectar: bool = false
var seleccion_desconectar_1: int = -1
var prim = preload("res://Mision_3/Mision 3/Prim.gd").new()
const INF = 99999

func _ready():
	preparar_estaciones_y_conexiones()
	$"../UI/BotonConectar".pressed.connect(_on_BotonConectar_pressed)
	$"../UI/BotonDesconectar".pressed.connect(_on_boton_desconectar_pressed)
	$"../UI/BotonConfirmar".pressed.connect(_on_BotonConfirmar_pressed)
	#$"../UI/BotonVerOptima".pressed.connect(_on_BotonVerOptima_pressed)

func preparar_estaciones_y_conexiones():
	var ancho_pantalla = 640
	var alto_pantalla = 360
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	# ===== 3 GRAFOS FIJOS =====
	var grafos_fijos = [
		{
			"positions": [
				Vector2(280, 120),
				Vector2(380, 80),
				Vector2(480, 120),
				Vector2(520, 240),
				Vector2(360, 200),
				Vector2(240, 240)
			],
			"edges": [
				{"o":0,"d":1},
				{"o":1,"d":2},
				{"o":2,"d":3},
				{"o":3,"d":4},
				{"o":4,"d":5},
				{"o":5,"d":0},
				{"o":0,"d":2},
				{"o":1,"d":4}
			]
		},
		{
			"positions": [
				Vector2(240, 80),
				Vector2(320, 80),
				Vector2(340, 160),
				Vector2(300, 250),
				Vector2(520, 250)
			],
			"edges": [
				{"o":0,"d":2},
				{"o":1,"d":2},
				{"o":3,"d":2},
				{"o":4,"d":2},
				{"o":0,"d":3},
				{"o":1,"d":4}
			]
		},
		{
			"positions": [
				Vector2(240, 80),
				Vector2(340, 160),
				Vector2(480, 80),
				Vector2(500, 160),
				Vector2(460, 230),
				Vector2(300, 250),
				Vector2(260, 160)
			],
			"edges": [
				{"o":0,"d":1},
				{"o":1,"d":2},
				{"o":2,"d":3},
				{"o":3,"d":4},
				{"o":4,"d":5},
				{"o":5,"d":6},
				{"o":6,"d":0},
				{"o":1,"d":5},
				{"o":2,"d":4}
			]
		}
	]
	# ===== Selección aleatoria del grafo =====
	var seleccionado = rng.randi_range(0, grafos_fijos.size() - 1)
	var graf = grafos_fijos[seleccionado]
	var posiciones = graf["positions"]
	var aristas_definidas = graf["edges"]
	var cantidad_estaciones = posiciones.size()
	# --- LIMPIEZA ---
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
	# --- INSTANCIAR ESTACIONES ---
	for i in range(cantidad_estaciones):
		var pos = posiciones[i]
		var esta = preload("res://Mision_3/Mision 3/scenes/estacion.tscn").instantiate()
		esta.nombre = "Estacion_%d" % i
		esta.posicion = pos
		$EstacionContainer.add_child(esta)
		estaciones.append(esta)
		esta.input_event.connect(_on_estacion_input.bind(i))
	# --- RESALTAR INICIAL ---
	var idx_inicial = 0
	estaciones[idx_inicial].modulate = Color.BLUE
	# --- GENERAR ARISTAS CON PESOS ALEATORIOS ---
	var todas_aristas = []
	for a in aristas_definidas:
		var peso = rng.randi_range(1, 999)
		todas_aristas.append({"origen": a["o"], "destino": a["d"], "costo": peso})
	# --- Grafo diccionario bidireccional (para Prim y lógica de conexiones) ---
	grafo = {}
	for i in range(cantidad_estaciones):
		grafo["Estacion_%d" % i] = []
	for a in todas_aristas:
		var o = "Estacion_%d" % a["origen"]
		var d = "Estacion_%d" % a["destino"]
		var cost = a["costo"]
		grafo[o].append([d, cost])
		grafo[d].append([o, cost])
	# --- Dibuja conexiones posibles ---
	for a in todas_aristas:
		var conn = preload("res://Mision_3/Mision 3/scenes/conexion.tscn").instantiate()
		conn.inicializar(estaciones[a["origen"]], estaciones[a["destino"]], a["costo"])
		conn.modulate = Color(0.8,0.8,0.8,0.5)
		$ConexionContainer.add_child(conn)
		conexiones_posibles.append(conn)

func _on_BotonConectar_pressed():
	seleccionando = true
	seleccion_1 = -1
	for esta in estaciones:
		esta.modulate = Color.WHITE

func _on_estacion_input(viewport, event: InputEvent, shape_idx: int, idx_estacion: int):
	if seleccionando and event is InputEventMouseButton and event.pressed:
		if seleccion_1 == -1:
			seleccion_1 = idx_estacion
			estaciones[idx_estacion].modulate = Color.GREEN
		else:
			conectar_estaciones(seleccion_1, idx_estacion)
			estaciones[seleccion_1].modulate = Color.WHITE
			seleccion_1 = -1
	elif seleccionando_desconectar and event is InputEventMouseButton and event.pressed:
		if seleccion_desconectar_1 == -1:
			seleccion_desconectar_1 = idx_estacion
			estaciones[idx_estacion].modulate = Color.RED
		else:
			desconectar_estaciones(seleccion_desconectar_1, idx_estacion)
			estaciones[seleccion_desconectar_1].modulate = Color.WHITE
			seleccion_desconectar_1 = -1

func desconectar_estaciones(origen_idx: int, destino_idx: int):
	var esta_origen = estaciones[origen_idx]
	var esta_destino = estaciones[destino_idx]
	for conn in conexiones_jugador:
		if (conn.origen == esta_origen and conn.destino == esta_destino) \
		or (conn.origen == esta_destino and conn.destino == esta_origen):
			conn.modulate = Color(0.8,0.8,0.8,0.5)
			conexiones_jugador.erase(conn)
			mostrar_costo()
			return # Solo desconectamos una vez

# Aquí el botón confirmar te muestra si ganaste o perdiste
func _on_BotonConfirmar_pressed():
	var costo_player = calcular_costo_jugador()
	$"../UI/CostoLabel".text = "Tu costo: %d" % costo_player
	var mst = prim.prim(grafo, "Estacion_0")
	var costo_optimo = 0.0
	for conn in mst:
		costo_optimo += conn[2]
	$"../UI/OptimoLabel".text = "Costo óptimo: %d (Prim)" % costo_optimo
	_resaltar_mst(mst)

	# Comparación actual: ¿las conexiones del jugador son las mismas que el MST?
	if _es_ganador(mst):
		SceneTransitions.change_scene_to_file("res://Mision_3/Mision 3/scenes/winner.tscn")
	else:
		SceneTransitions.change_scene_to_file("res://Mision_3/Mision 3/scenes/loser.tscn")

func _es_ganador(mst: Array) -> bool:
	var jugador_set = []
	for conn in conexiones_jugador:
		var idx_origen = estaciones.find(conn.origen)
		var idx_destino = estaciones.find(conn.destino)
		var costo = conn.costo
		jugador_set.append([
			min(idx_origen, idx_destino),
			max(idx_origen, idx_destino),
			costo
		])
	var mst_set = []
	for conn in mst:
		var idx_origen = int(conn[0].split("_")[1])
		var idx_destino = int(conn[1].split("_")[1])
		var costo = conn[2]
		mst_set.append([
			min(idx_origen, idx_destino),
			max(idx_origen, idx_destino),
			costo
		])
	if jugador_set.size() != mst_set.size():
		return false
	for item in jugador_set:
		if not item in mst_set:
			return false
	return true

# --- SOLO PERMITE SI ES CONEXION VALIDA DISPONIBLE ---
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
		esta_origen.modulate = Color(1,0.6,0.2) # naranja
		esta_destino.modulate = Color(1,0.6,0.2)
		return
	var costo = obtener_costo(origen_idx, destino_idx)
	if costo == INF:
		return
	if not _generaria_ciclo(origen_idx, destino_idx):
# Encuentra la conexión visual existente
		for conn in conexiones_posibles:
			if (conn.origen == esta_origen and conn.destino == esta_destino) or \
	   			(conn.origen == esta_destino and conn.destino == esta_origen):
				conn.modulate = Color.YELLOW
				conexiones_jugador.append(conn)
				mostrar_costo()
				return
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

#func _on_BotonConfirmar_pressed():
	#var costo_player = calcular_costo_jugador()
	#$"../UI/CostoLabel".text = "Tu costo: %d" % costo_player
	#var mst = prim.prim(grafo, "Estacion_0")
	#var costo_optimo = 0.0
	#for conn in mst:
		#costo_optimo += conn[2]
	#$"../UI/OptimoLabel".text = "Costo óptimo: %d (Prim)" % costo_optimo
	#_resaltar_mst(mst)

func _on_boton_desconectar_pressed() -> void:
	seleccionando = false
	seleccionando_desconectar = true
	seleccion_desconectar_1 = -1
	for esta in estaciones:
		esta.modulate = Color.WHITE

# Si usas el botón de mostrar óptima, descomenta en _ready, y aquí:
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
