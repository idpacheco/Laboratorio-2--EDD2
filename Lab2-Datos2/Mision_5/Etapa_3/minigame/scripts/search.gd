extends Node

const TOTAL_AREAS := 5
const TIME_LIMIT := 30 # segundos

@onready var progress_bar: ProgressBar = $UI/ProgressBar
@onready var time_label: Label = $UI/TimeLabel
@onready var result_label: Label = $UI/ResultLabel

@onready var countdown_timer: Timer = $UI/CountdownTimer
@onready var end_timer: Timer = $UI/EndTimer

var found_count: int = 0
var clicked := {} # mapa para evitar doble conteo por área (clave: area_id)
var time_left: int = TIME_LIMIT
var finished: bool = false
var increment: float = 0.0

# Rutas a las Area2D (ajusta si tu escena tiene otros nombres)
var area_paths := [
	"Item_1/Area2D_1",
	"Item_2/Area2D_2",
	"Item_3/Area2D_3",
	"Item_4/Area2D_4",
	"Item_5/Area2D_5"
]

func _ready() -> void:
	increment = progress_bar.max_value / float(TOTAL_AREAS)
	progress_bar.value = 0
	result_label.text = ""
	result_label.visible = false
	time_left = TIME_LIMIT
	_update_time_label()

	# Conectar timers con Callables
	var call_countdown = Callable(self, "_on_CountdownTimer_timeout")
	if not countdown_timer.is_connected("timeout", call_countdown):
		countdown_timer.connect("timeout", call_countdown)
	var call_end = Callable(self, "_on_EndTimer_timeout")
	if not end_timer.is_connected("timeout", call_end):
		end_timer.connect("timeout", call_end)

	# Conectar cada Area2D: usamos Callable.bind(i) para "ligar" el id del área
	for i in range(area_paths.size()):
		var p = area_paths[i]
		var a = get_node_or_null(p)
		if a:
			var call_area = Callable(self, "_on_area_input").bind(i)
			# is_connected espera (signal, callable)
			if not a.is_connected("input_event", call_area):
				a.connect("input_event", call_area)
		else:
			push_warning("No se encontró Area2D en la ruta: %s" % p)

	# Arrancar timers
	countdown_timer.wait_time = 1.0
	countdown_timer.one_shot = false
	countdown_timer.start()

	end_timer.wait_time = float(TIME_LIMIT)
	end_timer.one_shot = true
	end_timer.start()

func _on_CountdownTimer_timeout() -> void:
	if finished:
		return
	time_left -= 1
	if time_left < 0:
		time_left = 0
	_update_time_label()

func _on_EndTimer_timeout() -> void:
	if finished:
		return
	if found_count >= TOTAL_AREAS:
		_win()
	else:
		_lose()

# Handler central para Area2D: recibe (viewport, event, shape_idx) y el area_id ligado al final por bind
func _on_area_input(viewport, event: InputEvent, shape_idx: int, area_id: int) -> void:
	if finished:
		return
	# Usar la constante correcta en 4.4
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if clicked.has(area_id):
			return
		clicked[area_id] = true
		found_count += 1
		progress_bar.value = clamp(progress_bar.value + increment, 0, progress_bar.max_value)

		var area_node = _get_area_by_id(area_id)
		if area_node:
			area_node.set_deferred("input_pickable", false)
			area_node.set_deferred("monitoring", false)

		if found_count >= TOTAL_AREAS:
			_win()

func _get_area_by_id(id: int) -> Node:
	if id >= 0 and id < area_paths.size():
		return get_node_or_null(area_paths[id])
	return null

func _update_time_label() -> void:
	var secs := int(max(time_left, 0))
	var minutes := secs / 60
	var seconds := secs % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]

func _win() -> void:
	finished = true
	countdown_timer.stop()
	end_timer.stop()
	SceneTransitions.change_scene_to_file("res://Mision_5/Etapa_3/minigame/scenes/ganaste.tscn")
	_disable_all_areas()

func _lose() -> void:
	finished = true
	countdown_timer.stop()
	end_timer.stop()
	SceneTransitions.change_scene_to_file("res://Mision_5/Etapa_3/minigame/scenes/perdiste.tscn")
	_disable_all_areas()

func _disable_all_areas() -> void:
	for i in range(area_paths.size()):
		var a = get_node_or_null(area_paths[i])
		if a:
			a.set_deferred("input_pickable", false)
			a.set_deferred("monitoring", false)

func restart() -> void:
	found_count = 0
	clicked.clear()
	progress_bar.value = 0
	time_left = TIME_LIMIT
	finished = false
	result_label.visible = false
	for i in range(area_paths.size()):
		var a = get_node_or_null(area_paths[i])
		if a:
			a.set_deferred("input_pickable", true)
			a.set_deferred("monitoring", true)
	countdown_timer.start()
	end_timer.start()
	_update_time_label()
