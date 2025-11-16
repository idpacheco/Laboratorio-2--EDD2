extends Control

const NODE_WIDGET = preload("res://Mision_1/Level1/scenes/ValidationNode.tscn")

@onready var nodes_container = $NodesContainer
@onready var button_confirm = $ButtonConfirm
@onready var label_feedback = $LabelFeedback

func _ready():
	_spawn_nodes()
	button_confirm.pressed.connect(_validate)

func _spawn_nodes():
	# Limpia si ya había algo
	for n in nodes_container.get_children():
		n.queue_free()

	for id in GameState.all_nodes:
		var widget = NODE_WIDGET.instantiate()

		# Setup ahora SOLO recibe id
		widget.setup(id)

		nodes_container.add_child(widget)

func _validate():
	var user_selected = []

	for widget in nodes_container.get_children():
		if widget.selected:
			user_selected.append(widget.node_id)

	print("Usuario seleccionó:", user_selected)
	print("Comprometidos reales:", GameState.compromised)

	if arrays_match_unordered(user_selected, GameState.compromised):
		label_feedback.text = "✔ ¡Correcto!"
	else:
		label_feedback.text = "❌ Incorrecto. Los nodos infectados eran: " + str(GameState.compromised)
		
func arrays_match_unordered(a: Array, b: Array) -> bool:
	if a.size() != b.size():
		return false

	for item in a:
		if not b.has(item):
			return false

	return true
