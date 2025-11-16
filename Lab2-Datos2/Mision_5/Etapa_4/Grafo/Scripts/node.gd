extends Area2D

@export var node_name: String = ""
@export var is_source: bool = false
@export var is_sink: bool = false

signal node_clicked(node_name: String)
@onready var sprite = $Sprite2D  # cambia el path si tu nodo es distinto
@onready var label = $Label
var default_color: Color = Color(1, 1, 1) # blanco
var selected_color: Color = Color(0, 0.4, 1) # azul
func _ready():
	label.text = node_name

# Detecta clic del jugador
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		emit_signal("node_clicked", node_name)

func set_selected(is_selected: bool):
	if is_selected:
		sprite.modulate = selected_color
	else:
		sprite.modulate = default_color
