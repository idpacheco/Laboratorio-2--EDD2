extends Line2D

@export var from_node: Node2D
@export var to_node: Node2D
@export var capacity: int = 10
@export var flow: int = 0

@onready var label: Label = $Label

# Colores configurables
var base_color_ok := Color(0, 1, 0)
var base_color_warning := Color(1, 1, 0)
var base_color_full := Color(1, 0, 0)
var highlight_color := Color(1, 0, 1)
var error_color := Color(1, 0, 0)

# Estado actual del color real
var current_base_color := Color(0, 1, 0)

var arrow_size := 20.0
var arrow_distance := 40.0
var arrow_angle := deg_to_rad(35)


func _ready():
	update_edge()


func update_edge():
	if from_node and to_node:

		var p1 = from_node.position
		var p2 = to_node.position

		# Dibujar la flecha usando puntos del Line2D
		_draw_arrow(p1, p2)

		# Texto
		label.position = (p1 + p2) / 2 - position
		label.text = str(flow) + "/" + str(capacity)

		# Elegir color según flujo
		if flow >= capacity:
			current_base_color = base_color_full
		elif flow > 0:
			current_base_color = base_color_warning
		else:
			current_base_color = base_color_ok

		self.default_color = current_base_color

		# Grosor dinámico
		width = 3 + (flow * 0.5)

		queue_redraw()


func _draw_arrow(p1: Vector2, p2: Vector2):
	var direction = (p2 - p1).normalized()

	# Base de la flecha alejada del nodo final
	var arrow_base = p2 - direction * arrow_distance

	var left_point = arrow_base + direction.rotated(arrow_angle) * arrow_size
	var right_point = arrow_base + direction.rotated(-arrow_angle) * arrow_size

	# Estructura de puntos para Line2D
	points = [
		p1, p2,      # línea principal
		left_point,  # costado izquierdo
		p2,
		right_point  # costado derecho
	]


# -------- Estados --------

func is_full() -> bool:
	return flow >= capacity


func highlight():
	self.default_color = highlight_color
	queue_redraw()


func set_error_state():
	self.default_color = error_color
	queue_redraw()


func reset_color():
	self.default_color = current_base_color
	queue_redraw()


func flash_error(duration := 0.6) -> void:
	set_error_state()
	await get_tree().create_timer(duration).timeout
	reset_color()
