extends Control

var node_id = ""
var selected = false


func _ready():
	# Para detectar clics en este nodo
	self.mouse_filter = Control.MOUSE_FILTER_PASS
	self.set_process_input(true)

func setup(id: String):
	node_id = id
	var tex_path = "res://Mision_1/Level1/Assets/Node_%s.png" % id
	var tex = load(tex_path)
	$Sprite2D.texture = tex

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if get_global_rect().has_point(event.position):
			_toggle_selection()

func _toggle_selection():
	selected = !selected
	if selected:
		self.modulate = Color(0.6, 1.0, 0.6)  # tono verdoso
	else:
		self.modulate = Color(1, 1, 1)
