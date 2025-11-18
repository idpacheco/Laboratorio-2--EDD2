extends Node2D

# ---------- CONFIG ----------
var state = 5
const NODE_COUNT: int = 10
const NODE_RADIUS: int = 6
const HORSE_SPEED: float = 200.0  
const MIN_NODE_DISTANCE: float = 60.0
const HORSE_COLORS: Array = [
	Color(1, 0, 0),
	Color(0, 0, 1),
	Color(0, 1, 0),
	Color(1, 1, 0),
	Color(1, 0, 1)
]
const START_COLOR: Color = Color(1, 0.5, 0)
const END_COLOR: Color = Color(0, 1, 1)
@onready var controler: Node2D = $"."

# ---------- ESTADO ----------
var nodes: Array[Vector2] = []
var edges: Dictionary = {}
var paths: Array = []
var horses: Array = []
var horse_progress: Array[int] = []
var running: bool = false
var race_finished: bool = false
var selected_horse: int = 0

var font: FontFile

# ---------- READY ----------
func _ready():
	randomize()
	# Asegúrate de que este archivo de fuente exista en tu proyecto.
	font = preload("res://Mision_2/Assets/Poco.ttf") 

	asegurar_estructura_basica()
	horses = $Horses.get_children()

	if horses.size() < 5:
		crear_caballos_visuales()

	var start_btn = get_node_or_null("CanvasLayer/StartButton") as Button
	var reset_btn = get_node_or_null("CanvasLayer/ResetButton") as Button
	if start_btn:
		start_btn.pressed.connect(start_race)
	if reset_btn:
		reset_btn.pressed.connect(reset_race)

	generate_graph()
	assign_paths()

# ---------- ASEGURAR ESTRUCTURA ----------
func asegurar_estructura_basica():
	if not has_node("Horses"):
		var h = Node2D.new()
		h.name = "Horses"
		add_child(h)

	if not has_node("CanvasLayer"):
		var cl = CanvasLayer.new()
		cl.name = "CanvasLayer"
		add_child(cl)

		var start_btn = Button.new()
		start_btn.name = "StartButton"
		start_btn.text = "Start"
		start_btn.position = Vector2(20, 20)
		cl.add_child(start_btn)

		var reset_btn = Button.new()
		reset_btn.name = "ResetButton"
		reset_btn.text = "Reset"
		reset_btn.position = Vector2(120, 20)
		cl.add_child(reset_btn)

# ---------- CREAR CABALLOS ----------
func crear_caballos_visuales():
	var container = $Horses
	for i in range(5):
		var c = ColorRect.new()
		c.name = "Horse%d" % i
		c.size = Vector2(18, 18)
		c.color = HORSE_COLORS[i]
		c.position = Vector2(100, 100)
		container.add_child(c)
	horses = container.get_children()

# ---------- INPUT ----------
func _input(event):
	for i in range(5):
		if event.is_action_pressed("ui_select_%d" % (i + 1)): 
			selected_horse = i
			print("Seleccionaste el caballo ", i + 1)

# ---------- GENERAR GRAFO ----------
func generate_graph():
	nodes.clear()
	edges.clear()

	# Nodo inicial (0)
	var start_pos = Vector2(130, 160)
	nodes.append(start_pos)
	edges[0] = []

	# Nodo final (1)
	var goal_pos = Vector2(520, 160)
	nodes.append(goal_pos)
	edges[1] = []

	# Nodos intermedios
	for i in range(2, NODE_COUNT):
		var new_pos: Vector2
		var tries = 0
		while true:
			new_pos = Vector2(randf_range(130, 520), randf_range(70, 240))
			var too_close = false
			for n in nodes:
				if n.distance_to(new_pos) < MIN_NODE_DISTANCE:
					too_close = true
					break
			if not too_close:
				break
			tries += 1
			if tries > 100: 
				break 
		nodes.append(new_pos)
		edges[i] = []

	# Conectar inicio y fin con 5 nodos intermedios cada uno
	while edges[0].size() < 5:
		var target = 2 + randi() % (NODE_COUNT - 2)
		if edges[0].any(func(e): return e["to"] == target): 
			continue
		var w := randi_range(1, 5)
		edges[0].append({"to": target, "weight": w})
		edges[target].append({"to": 0, "weight": w})

	while edges[1].size() < 5:
		var target = 2 + randi() % (NODE_COUNT - 2)
		if edges[1].any(func(e): return e["to"] == target):
			continue
		var w := randi_range(1, 5)
		edges[1].append({"to": target, "weight": w})
		edges[target].append({"to": 1, "weight": w})

	# Conexiones básicas entre nodos intermedios
	for i in range(2, NODE_COUNT):
		var c := randi() % (i - 1) + 2
		var w := randi_range(1, 5)
		if not edges[i].any(func(e): return e["to"] == c):
			edges[i].append({"to": c, "weight": w})
			edges[c].append({"to": i, "weight": w})

	# Conexiones adicionales aleatorias
	for i in range(2, NODE_COUNT):
		for j in range(i + 1, NODE_COUNT):
			if randf() < 0.18:
				var w := randi_range(1, 5)
				if not edges[i].any(func(e): return e["to"] == j):
					edges[i].append({"to": j, "weight": w})
					edges[j].append({"to": i, "weight": w})

	queue_redraw()

# ---------- DIBUJAR ----------
func draw_text_center(pos: Vector2, text: String, color: Color):
	if font == null:
		return
	var size := font.get_string_size(text)
	draw_string(font, pos - size * 0.5, text, HORIZONTAL_ALIGNMENT_CENTER, -1, 20, color)

func _draw():
	# Dibujar aristas y mostrar peso
	for i in range(NODE_COUNT):
		for e in edges[i]:
			var j = e["to"]
			if i < j:
				var a = nodes[i]
				var b = nodes[j]
				draw_line(a, b, Color(0.8,0.8,0.8), 2)
				var mid = (a + b) * 0.5
				draw_text_center(mid, str(e["weight"]), Color(1,1,1))

	# Dibujar caminos de caballos
	var path_offsets := [Vector2(-3,-3), Vector2(3,-3), Vector2(-3,3), Vector2(3,3), Vector2(0,0)]
	for i in range(min(paths.size(), HORSE_COLORS.size())):
		var path = paths[i]
		if path.size() < 2:
			continue
		var col = HORSE_COLORS[i]
		for k in range(path.size() - 1):
			var start_pos = nodes[path[k]]
			var end_pos = nodes[path[k+1]] 
			draw_line(start_pos, end_pos, col, 3)

	# Dibujar nodos
	for idx in range(nodes.size()):
		if idx == 0:
			draw_circle(nodes[idx], NODE_RADIUS, START_COLOR)
		elif idx == 1:
			draw_circle(nodes[idx], NODE_RADIUS, END_COLOR)
		else:
			draw_circle(nodes[idx], NODE_RADIUS, Color(0.9,0.7,0.2))

# ---------- DIJKSTRA ----------
func dijkstra_custom(start: int, goal: int, local_edges: Dictionary) -> Array:
	var dist = {}
	var prev = {}
	var q: Array[int] = []

	for i in range(NODE_COUNT):
		dist[i] = INF
		prev[i] = null
		q.append(i)

	dist[start] = 0.0

	while not q.is_empty():
		q.sort_custom(func(a, b): return dist[a] < dist[b])
		var u = q.pop_front()
		if u == goal:
			break
		
		if not local_edges.has(u): 
			continue
			
		for e in local_edges[u]:
			var v = e["to"]
			# El costo es el tiempo de viaje estimado: weight / speed
			# Usamos float() para asegurar la aritmética correcta.
			var alt = dist[u] + float(e["weight"]) / HORSE_SPEED 
			if alt < dist[v]:
				dist[v] = alt
				prev[v] = u

	var path: Array[int] = []
	var c = goal
	while c != null:
		path.push_front(c)
		c = prev[c]

	if path.size() == 0 or path[0] != start:
		return []
	return path

# ---------- ASIGNAR RUTAS ÚNICAS CON PENALIZACIÓN ADAPTATIVA (CORREGIDO) ----------
func assign_paths():
	paths.clear()
	horse_progress.clear()
	var start = 0
	var goal = 1

	# Para cada caballo
	for i in range(5):
		var attempts = 0
		var max_attempts = 20
		var found_path = false
		var path = []

		# Copia del grafo para penalizar aristas usadas
		var temp_edges = {}
		for key in edges.keys():
			temp_edges[key] = []
			for e in edges[key]:
				var edge_copy = e.duplicate()
				edge_copy["weight"] = float(edge_copy["weight"])
				temp_edges[key].append(edge_copy)

		while attempts < max_attempts and not found_path:
			attempts += 1

			# Mezclar los pesos para aleatoriedad
			var current_edges = {}
			for key in temp_edges.keys():
				current_edges[key] = []
				for e in temp_edges[key]:
					var w = e["weight"]
					if randf() < 0.3:
						w *= randf_range(1.3, 2.0)
					current_edges[key].append({"to": e["to"], "weight": w})

			# Calcular ruta
			path = dijkstra_custom(start, goal, current_edges)

			if path.size() < 2:
				break

			# Comprobar unicidad
			found_path = true
			for existing in paths:
				if existing == path:
					found_path = false
					break

			# Penalizar aristas usadas si el camino es duplicado
			if not found_path:
				var mid_nodes = []
				for k in range(1, path.size()-1):
					mid_nodes.append(path[k])
				if not mid_nodes.is_empty():
					var t = mid_nodes[randi() % mid_nodes.size()]
					var s = path[path.find(t)-1]
					for e in temp_edges[s]:
						if e["to"] == t:
							e["weight"] *= randf_range(5.0, 10.0)
					for e in temp_edges[t]:
						if e["to"] == s:
							e["weight"] *= randf_range(5.0, 10.0)

		# Guardar ruta y progreso
		if path.size() < 2 or not found_path:
			paths.append([])
			horse_progress.append(0)
			horses[i].position = Vector2(-1000,-1000)
		else:
			paths.append(path)
			horse_progress.append(0)
			horses[i].position = nodes[start]


# ---------- BOTONES ----------
func start_race():
	if running:
		return
	running = true
	race_finished = false

func reset_race():
	running = false
	race_finished = false
	generate_graph()
	assign_paths()

# ---------- PROCESS ----------
func _process(delta: float):
	if not running:
		return
	for i in range(5):
		move_horse(i, delta)
	var all_finished = true
	for i in range(5):
		if horse_progress[i] < paths[i].size() - 1:
			all_finished = false
			break

	if all_finished:
		running = false
		print("🏁 Todos los caballos llegaron a la meta.")


# ---------- MOVIMIENTO ----------
func move_horse(i: int, delta: float):
	if i >= paths.size() or paths[i].size() < 2:
		return

	var prog = horse_progress[i]
	if prog >= paths[i].size() - 1:
		return

	var a = paths[i][prog]
	var b = paths[i][prog+1]
	var weight = 1.0 
	
	# Usar el peso original para el cálculo de movimiento
	for e in edges[a]: 
		if e["to"] == b:
			weight = float(e["weight"]) 
			break

	var dir = (nodes[b] - horses[i].position).normalized()
	horses[i].position += dir * HORSE_SPEED / weight * delta

	# Comprobar si ha pasado el nodo B
	var to_target = nodes[b] - horses[i].position
	if dir.dot(to_target) <= 0:
		horses[i].position = nodes[b]
		horse_progress[i] += 1
		if horse_progress[i] >= paths[i].size() - 1:
			declare_winner(i)

# ---------- GANADOR ----------
func declare_winner(index: int):
	if race_finished:
		return
	race_finished = true  # solo marcamos que ya hay ganador
	print("El caballo ganador es el #%d" % (index))
	if controler.state == index:
		print("ganaste")
		SceneTransitions.change_scene_to_file("res://Mision_2/Scene/win.tscn")
		AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
		AudioManager.SFXPlayer.play()
	elif controler.state == 5:
		print("No seleccionaate ningun competidor")
	else:
		print("perdiste ",controler.state)

func _on_blue_pressed() -> void:
	state = 1

func _on_red_pressed() -> void:
	state = 0

func _on_green_pressed() -> void:
	state = 2

func _on_yellow_pressed() -> void:
	state = 3

func _on_magenta_pressed() -> void:
	state = 4
