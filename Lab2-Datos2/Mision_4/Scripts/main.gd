extends Node2D

var NodeScene: PackedScene = load("res://Mision_4/Scenes/Node.tscn")
var EdgeScene: PackedScene = load("res://Mision_4/Scenes/Edge.tscn")

@onready var nodes_container = $NodesContainer
@onready var edges_container = $EdgesContainer
@onready var button = $Button
@onready var mensaje_final = $MensajeFinal
@onready var button_auto = $CheckButtonAuto
@onready var game_timer = $GameTimer
@onready var tiempo_label = $TiempoLabel
@export var tiempo_limite: float = 60

var cancel_algorithm = false
var step_mode: bool = false
var saved_player_flows = {}

var nodes = {}
var edges = []
var selected_path = []
var total_flow = 0

# Variables para control de tiempo y errores
var errores_jugador = 0
var tiempo_inicio = 0.0
var tiempo_restante: float
var jugador_gano = false

func _ready():
	tiempo_inicio = Time.get_ticks_msec()
	create_graph()
	button.pressed.connect(run_player_flow)

	button_auto.visible = false
	button_auto.pressed.connect(show_algorithm_mode)

	for n in nodes.values():
		n.node_clicked.connect(_on_node_clicked)
		
	game_timer.timeout.connect(_on_game_timer_timeout) 
	tiempo_restante = tiempo_limite
	game_timer.wait_time = tiempo_limite
	tiempo_label.text = "Tiempo: %d s" % tiempo_restante
	game_timer.stop()
	game_timer.start()

func _process(delta):
	if game_timer.is_stopped():
		return

	tiempo_restante -= delta
	if tiempo_restante < 0:
		tiempo_restante = 0
	
	tiempo_label.text = "Tiempo: %d s" % int(tiempo_restante)

#  Crear el grafo con capacidades aleatorias
func create_graph():
	var s = create_node("S", Vector2(100, 300), true, false)
	var a = create_node("A", Vector2(300, 200))
	var b = create_node("B", Vector2(300, 400))
	var c = create_node("C", Vector2(200, 450))
	var t = create_node("T", Vector2(500, 300), false, true)

	randomize()
	create_edge("S", "A", randi_range(4, 12))
	create_edge("S", "C", randi_range(4, 12))
	create_edge("A", "B", randi_range(4, 12))
	create_edge("B", "T", randi_range(4, 12))
	create_edge("C", "B", randi_range(4, 12))
	create_edge("A", "T", randi_range(4, 12))
	create_edge("C", "A", randi_range(4, 12))

func create_node(name: String, pos: Vector2, is_source := false, is_sink := false):
	var n = NodeScene.instantiate()
	n.position = pos
	n.node_name = name
	n.is_source = is_source
	n.is_sink = is_sink
	nodes_container.add_child(n)
	nodes[name] = n
	return n

func create_edge(from_name: String, to_name: String, cap: int):
	var edge = EdgeScene.instantiate()
	edge.from_node = nodes[from_name]
	edge.to_node = nodes[to_name]
	edge.capacity = cap
	edge.flow = 0
	edges_container.add_child(edge)
	edges.append(edge)



# Buscar arista en cualquier sentido (devuelve la arista y un flag si está en sentido inverso)
func get_edge_any_direction(a: String, b: String):
	for e in edges:
		if e.from_node.node_name == a and e.to_node.node_name == b:
			return [e, false]
		if e.from_node.node_name == b and e.to_node.node_name == a:
			return [e, true]
	return [null, false]


# Manejo visual/errores cuando el jugador selecciona en dirección errada
func handle_wrong_direction(edge: Node):
	errores_jugador += 1
	log_mensj("❌ Selección inválida: dirección equivocada en arista %s -> %s" % [edge.from_node.node_name, edge.to_node.node_name])
	# resalta la arista equivocada momentáneamente
	await edge.flash_error()
	# limpiar selección actual
	selected_path.clear()
	for n in nodes.values():
		n.set_selected(false)


func _on_node_clicked(node_name: String):
	# Si el jugador no ha empezado y el nodo no es la fuente, indicar inicio en s
	if selected_path.is_empty() and not nodes[node_name].is_source:
		log_mensj("Debes empezar desde la fuente (S).")
		return

	# Quita selección previa visual
	for n in nodes.values():
		n.set_selected(false)

	# Si es el primer nodo en el camino
	if selected_path.is_empty():
		nodes[node_name].set_selected(true)
		selected_path.append(node_name)
		log_info("Camino actual: " + str(selected_path))
		return

	# Si ya hay un nodo seleccionado, comprobar que la nueva selección sea válida en sentido directed
	var last = selected_path[selected_path.size() - 1]
	
	var direct_edge = get_edge_between(last, node_name)
	if direct_edge != null:
		#  dirección válida se agrega el camino
		nodes[node_name].set_selected(true)
		selected_path.append(node_name)
		log_info("Camino actual: " + str(selected_path))
		# si llegamos al sumidero aplicamos flujo
		if nodes[node_name].is_sink:
			apply_flow_to_path()
		return

	# Si no hay arista en sentido correcto, ver si existe en sentido contrario 
	var pair = get_edge_any_direction(last, node_name)
	var any_edge = pair[0]
	var is_inverted = pair[1]
	if any_edge != null and is_inverted:
		# Existe arista pero en sentido inverso 
		await handle_wrong_direction(any_edge)
		return

	# Si no existe arista en ningún sentido
	if any_edge == null:
		errores_jugador += 1
		log_mensj("❌ No hay arista entre %s y %s." % [last, node_name])
		selected_path.clear()
		for n in nodes.values():
			n.set_selected(false)
		return

# Aplicar flujo al camino seleccionado
func apply_flow_to_path():
	if selected_path.size() < 2:
		log_mensj("Camino incompleto.")
		selected_path.clear()
		return

	var path_edges = []
	for i in range(selected_path.size() - 1):
		var from = selected_path[i]
		var to = selected_path[i + 1]
		var edge = get_edge_between(from, to)
		if edge == null:
			log_mensj("❌ No hay arista entre %s y %s" % [from, to])
			errores_jugador += 1
			selected_path.clear()
			return
		if edge.is_full():
			log_mensj("Camino bloqueado: %s -> %s" % [from, to])
			errores_jugador += 1
			selected_path.clear()
			return
		path_edges.append(edge)

	var bottleneck = INF
	for e in path_edges:
		bottleneck = min(bottleneck, e.capacity - e.flow)

	for e in path_edges:
		e.flow += bottleneck
		e.update_edge()

	total_flow += bottleneck
	log_mensj2("Flujo enviado: %d por %s" % [bottleneck, str(selected_path)])
	#log_info("Flujo total: %d" % total_flow)

	selected_path.clear()
	check_end_game()
	for n in nodes.values():
		n.set_selected(false)

#  Buscar arista
func get_edge_between(from_name: String, to_name: String):
	for e in edges:
		if e.from_node.node_name == from_name and e.to_node.node_name == to_name:
			return e
	return null

#  Fin del juego
func check_end_game():
	var next_path = find_augmenting_path("S", "T")

	if next_path.is_empty():
		var ford_result = await ford_fulkerson(false)
		var duracion = (Time.get_ticks_msec() - tiempo_inicio) / 1000.0

		mensaje_final.text = " Flujo jugador: %d | Flujo máximo: %d\n Errores: %d" % [total_flow, ford_result, errores_jugador]
		mensaje_final.visible = true

		button_auto.visible = true
		
		$Continue.visible = true
		
		# condiciones de victoria
		jugador_gano = (
		total_flow == ford_result   # flujo perfecto
		and errores_jugador == 0    # sin errores
		and tiempo_restante > 0     # Tiempo
		)

		print("🏁 Juego terminado.")
		if errores_jugador > 0:
			log_mensj("⚠ Demasiados errores. NEMESIS casi corrompe la red...")
		else:
			log_mensj("✅ Flujo seguro establecido. NEMESIS ha sido aislado.")
		# detener
		game_timer.stop()
	else:
		log_mensj(" Aún quedan caminos posibles. Sigue intentando.")


func run_player_flow():
	print(" Reiniciando el juego...")

	total_flow = 0
	selected_path.clear()
	errores_jugador = 0
	tiempo_inicio = Time.get_ticks_msec()

	for e in edges:
		e.flow = 0
		e.update_edge()

	mensaje_final.visible = false
	get_tree().paused = false

	print("✅ Grafo reiniciado. Puedes comenzar desde S.")

	tiempo_restante = tiempo_limite  # REINICIA EL TIEMPO CADA VEZ
	tiempo_label.text = "Tiempo: %d s" % tiempo_restante
	if has_node("GameTimer"):
		game_timer.stop()
		game_timer.start()
		print("Temporizador iniciado (60s).")


#  Ford-Fulkerson 
func ford_fulkerson(show_paths := false) -> int:
	var g = {}
	for e in edges:
		if not g.has(e.from_node.node_name):
			g[e.from_node.node_name] = {}
		g[e.from_node.node_name][e.to_node.node_name] = e.capacity

	var source = "S"
	var sink = "T"
	var max_flow = 0

	while true:
		var visited = {}
		var parent = {}
		if not dfs(g, source, sink, visited, parent):
			break

		var path = []
		var v = sink
		var bottleneck = INF
		while v != source:
			var u = parent[v]
			path.insert(0, u)
			bottleneck = min(bottleneck, g[u][v])
			v = u
		path.append(sink)

		max_flow += bottleneck
		v = sink
		while v != source:
			var u = parent[v]
			g[u][v] -= bottleneck
			v = u

		
		if show_paths:
			log_mensj2("Camino aumentante encontrado: " + str(path) + " (Flujo enviado " + str(bottleneck) + ")")
			apply_auto_flow(path)
			await get_tree().create_timer(1.0).timeout

	return max_flow

func dfs(g, u, sink, visited, parent) -> bool:
	visited[u] = true
	if u == sink:
		return true
	for v in g.get(u, {}).keys():
		if not visited.has(v) and g[u][v] > 0:
			parent[v] = u
			if dfs(g, v, sink, visited, parent):
				return true
	return false

# Mostrar algoritmo visual
func show_algorithm_mode():
	$Panel/RichTextLabel3.clear()
	log_mensj(" Visualizando Ford-Fulkerson...")
	saved_player_flows.clear()
	for e in edges:
		saved_player_flows[e] = e.flow

	
	for e in edges:
		e.flow = 0
		e.update_edge()

	await get_tree().create_timer(0.5).timeout

	
	await ford_fulkerson(true)
	
	
	log_mensj("✅ Visualización completada.")

	
	for e in saved_player_flows.keys():
		e.flow = saved_player_flows[e]
		e.update_edge()

#  Búsqueda de camino y flujo auto

func find_augmenting_path(source: String, sink: String) -> Array:
	var queue = [source]
	var parent = {}
	parent[source] = null

	while queue.size() > 0:
		var current = queue.pop_front()
		for e in edges:
			if e.from_node.node_name == current:
				var residual = e.capacity - e.flow
				if residual > 0 and not parent.has(e.to_node.node_name):
					parent[e.to_node.node_name] = current
					queue.append(e.to_node.node_name)
					if e.to_node.node_name == sink:
						var result = [sink]
						var temp = sink
						while parent[temp] != null:
							result.push_front(parent[temp])
							temp = parent[temp]
						return result
	return []

func apply_auto_flow(path: Array):
	var path_edges = []
	for i in range(path.size() - 1):
		var e = get_edge_between(path[i], path[i + 1])
		path_edges.append(e)
	var b = INF
	for e in path_edges:
		b = min(b, e.capacity - e.flow)
	for e in path_edges:
		e.flow += b
		e.default_color = Color(1, 0, 1)
		e.update_edge()

func _on_game_timer_timeout() -> void:
	mensaje_final.text = "⏱️ Tiempo agotado. El sistema fue sobrecargado. NEMESIS ganó."
	mensaje_final.visible = true
	button_auto.visible = false
	get_tree().paused = true
	log_mensj("💥 El tiempo se acabó.")

func log_info(text):
	print(text)
	var label2= $Panel/RichTextLabel
	$Panel/RichTextLabel.append_text(text + "\n")
	label2.clear()               
	label2.append_text(text)     

func log_mensj(text):
	print(text)
	var label= $Panel/RichTextLabel2
	$Panel/RichTextLabel2.append_text(text + "\n")
	label.clear()               
	label.append_text(text)    


func log_mensj2(text):
	print(text)
	var label= $Panel/RichTextLabel3
	$Panel/RichTextLabel3.append_text(text + "\n")
	label.clear()               
	label.append_text(text)     


func _on_continue_pressed() -> void:
	if jugador_gano:
		get_tree().change_scene_to_file("res://Mision_4/Scenes/Ganaste.tscn")
	else:
		get_tree().change_scene_to_file("res://Mision_4/Scenes/Perdiste.tscn")
	pass 
