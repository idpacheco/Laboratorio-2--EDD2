extends Node2D

@onready var graph = $Graph
@onready var line_layer = $Graph/LineLayer
@onready var node_layer = $Graph/NodeLayer
@onready var button_start = $UI/ButtonStart
@onready var option_algorithm = $UI/OptionAlgorithm
@onready var label_structure = $UI/LabelStructure
@onready var label_status = $UI/LabelStatus

const NODE_SCENE = preload("res://Mision_5/Etapa_1/grafo/scenes/GraphNode.tscn")

var node_map = {}
var adjacency = {}
var order = []

# --- INFO TEMÁTICA (SOLO NOMBRES, SIN COMPROMISO FIJO) ---
var server_info = {
	"A": {"name": "Firewall Central"},
	"B": {"name": "Servidor de Correo"},
	"C": {"name": "Base de Datos"},
	"D": {"name": "Servidor Web"},
	"E": {"name": "Servidor DNS"},
	"F": {"name": "Proxy"}
}

# Lista REAL de nodos infectados (aleatoria)
var compromised_nodes = []


func _ready():
	button_start.pressed.connect(_on_start_pressed)

	_generate_random_graph(6, 8)  # 6 nodos, 8 aristas
	_assign_random_compromised() # EJEMPLO → 2 nodos infectados


# ---------------------------------------------------------
# GENERAR NODOS INFECTADOS ALEATORIAMENTE
# ---------------------------------------------------------
func _assign_random_compromised():
	compromised_nodes.clear()

	var keys = node_map.keys()
	keys.shuffle()

	# Número aleatorio entre 1 y 6
	var random_count = randi_range(1, keys.size())

	for i in range(random_count):
		compromised_nodes.append(keys[i])

	print("🔥 Nodos comprometidos generados:", compromised_nodes)


# ---------------------------------------------------------
# GENERAR GRAFO ALEATORIO EN CÍRCULO
# ---------------------------------------------------------
func _generate_random_graph(node_count:int, edge_count:int):
	randomize()

	var viewport_size = get_viewport().get_visible_rect().size
	var center = viewport_size / 2
	var radius = min(viewport_size.x, viewport_size.y) * 0.3

	# Limpiar
	for c in node_layer.get_children(): c.queue_free()
	for c in line_layer.get_children(): c.queue_free()

	node_map.clear()
	adjacency.clear()

	var step = TAU / node_count

	for i in range(node_count):
		var n = NODE_SCENE.instantiate()
		var id = char(65 + i)   # A,B,C...

		var angle = step * i
		var pos = center + Vector2(cos(angle), sin(angle)) * radius

		n.position = pos
		n.node_id = id
		node_layer.add_child(n)

		node_map[id] = n
		adjacency[id] = []

	# Crear aristas
	var pairs = []
	for a in node_map.keys():
		for b in node_map.keys():
			if a != b and not pairs.has([b, a]):
				pairs.append([a, b])

	pairs.shuffle()

	for i in range(min(edge_count, pairs.size())):
		var a = pairs[i][0]
		var b = pairs[i][1]
		adjacency[a].append(b)
		adjacency[b].append(a)

	# Ordenar adyacencia A→Z
	for k in adjacency.keys():
		adjacency[k].sort()

	_draw_edges()



# ---------------------------------------------------------
# DIBUJAR ARISTAS
# ---------------------------------------------------------
func _draw_edges():
	line_layer.adjacency = adjacency
	line_layer.node_map = node_map
	line_layer.queue_redraw()


# ---------------------------------------------------------
# BOTÓN START
# ---------------------------------------------------------
func _on_start_pressed():
	for n in node_map.values(): n.reset()
	order.clear()

	var start_id = "A"
	var selected = option_algorithm.get_item_text(option_algorithm.selected)

	if selected == "BFS":
		order = await _bfs(start_id)
	else:
		order = await _dfs(start_id)

	await _run_animation()


# ---------------------------------------------------------
# BFS ORDENADO
# ---------------------------------------------------------
func _bfs(start_id:String) -> Array:
	var visited = {}
	var q = [start_id]
	var res = []

	visited[start_id] = true

	while q.size() > 0:

		label_structure.text = "Cola: " + str(q)
		await get_tree().create_timer(0.6).timeout

		var u = q.pop_front()
		res.append(u)

		for v in adjacency[u]:
			if not visited.has(v):
				visited[v] = true
				q.append(v)

	label_structure.text = "Cola vacía ✔"
	return res


# ---------------------------------------------------------
# DFS ORDENADO
# ---------------------------------------------------------
func _dfs(start_id:String) -> Array:
	var visited = {}
	var stack = [start_id]
	var res = []

	while stack.size() > 0:
		label_structure.text = "Pila: " + str(stack)
		await get_tree().create_timer(0.6).timeout

		var u = stack.pop_back()
		if not visited.has(u):
			visited[u] = true
			res.append(u)

			# Push neighbors in reverse order so the smallest is visited first
			var neigh = adjacency[u].duplicate()
			neigh.reverse()
			for v in neigh:
				if not visited.has(v):
					stack.append(v)

	label_structure.text = "Pila vacía ✔"
	return res


# ---------------------------------------------------------
# ANIMACIÓN FINAL CON INFO DE SERVIDOR E INFECCIÓN
# ---------------------------------------------------------
func _run_animation():
	await get_tree().create_timer(0.5).timeout

	for id in order:
		var node = node_map[id]
		node.mark_visited()

		var name = server_info[id]["name"]

		if compromised_nodes.has(id):
			label_status.text = "⚠️ " + id + " - " + name + "  (COMPROMETIDO)"
		else:
			label_status.text = "🟢 " + id + " - " + name + "  (Seguro)"

		await get_tree().create_timer(0.8).timeout

	print("Recorrido final:", order)

	# --------------------------------------------------
	#  GUARDAR INFORMACIÓN GLOBAL PARA LA PANTALLA FINAL
	# --------------------------------------------------

	GameState.all_nodes = node_map.keys()
	GameState.compromised = compromised_nodes.duplicate()

	var selected_algorithm = option_algorithm.get_item_text(option_algorithm.selected)

	if selected_algorithm == "BFS":
		GameState.bfs_order = order.duplicate()
	else:
		GameState.dfs_order = order.duplicate()

	if GameState.has_both_traversals():
		print("✔ Ambos recorridos listos, cargando Validación...")
		get_tree().change_scene_to_file("res://Mision_5/Etapa_1/grafo/scenes/validacion.tscn")
	else:
		print("📌 Aún falta un recorrido. Ejecuta el otro.")


func _on_help_button_pressed() -> void:
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()
	SceneTransitions.change_scene_to_file("res://Mision_5/Etapa_1/grafo/scenes/help.tscn")
