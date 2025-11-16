extends Area2D

@export var node_name: String = ""
@export var is_source: bool = false
@export var is_sink: bool = false

signal node_clicked(node_name: String)

@onready var label = $Label

func _ready():
	label.text = node_name

# Detecta clic del jugador
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		emit_signal("node_clicked", node_name)
