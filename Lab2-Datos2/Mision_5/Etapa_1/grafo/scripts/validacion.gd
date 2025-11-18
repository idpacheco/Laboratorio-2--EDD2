extends Control

const NODE_WIDGET = preload("res://Mision_5/Etapa_1/grafo/scenes/ValidationNode.tscn")

@onready var nodes_container = $NodesContainer
@onready var button_confirm = $ButtonConfirm
@onready var label_feedback = $LabelFeedback
@onready var win = $win
@onready var lose = $lose

func _ready():
	win.visible = false
	lose.visible = false
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


	if arrays_match_unordered(user_selected, GameState.compromised):
		win.visible = true
	else:
		lose.visible = true
		
func arrays_match_unordered(a: Array, b: Array) -> bool:
	if a.size() != b.size():
		return false

	for item in a:
		if not b.has(item):
			return false

	return true


func _on_try_again_pressed() -> void:
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()
	SceneTransitions.change_scene_to_file("res://Mision_5/Etapa_1/grafo/scenes/grafo_etapa1.tscn")


func _on_win_pressed() -> void:
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()
	SceneTransitions.change_scene_to_file("res://Mision_5/Etapa_1/minijuego/scenes/inicio_etapa1.tscn")
