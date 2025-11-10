extends Control

const QTE1_SCENE = preload("res://Mision_3/Minijuego_Mision3/scenes/qte1.tscn")
const IMAGE1_KEYS = [
	{ "file": "res://Mision_3/Minijuego_Mision3/assests/Malware.png", "key": KEY_1},
	{ "file": "res://Mision_3/Minijuego_Mision3/assests/Phising.png", "key": KEY_2 },
	{ "file": "res://Mision_3/Minijuego_Mision3/assests/SQL Injection.png", "key": KEY_3 },
	{ "file": "res://Mision_3/Minijuego_Mision3/assests/Spyware.png", "key": KEY_4 }
]
const QTE2_SCENE = preload("res://Mision_3/Minijuego_Mision3/scenes/qte_2.tscn")
const IMAGE2_KEYS = [
	{ "file": "res://Mision_3/Minijuego_Mision3/assests/Malware.png", "key": KEY_M},
	{ "file": "res://Mision_3/Minijuego_Mision3/assests/Phising.png", "key": KEY_P },
	{ "file": "res://Mision_3/Minijuego_Mision3/assests/SQL Injection.png", "key": KEY_S },
	{ "file": "res://Mision_3/Minijuego_Mision3/assests/Spyware.png", "key": KEY_Y }
]

@export var points_to_win := 1000
@export var points_per_success := 100
@export var points_per_fast_success := 150
@export var points_per_fail := -200
@export var fast_time := 0.5

@onready var score_label: Label = %ScoreLabel

var score: int = 0
var game_over: bool = false
var qte1_instance = null
var qte2_instance = null

func _ready():
	score = 0
	game_over = false
	_update_score()
	_spawn_qte1()
	_spawn_qte2()

func _spawn_qte1():
	if game_over:
		return
	if qte1_instance:
		qte1_instance.queue_free()
	var choice1 = IMAGE1_KEYS[randi() % IMAGE1_KEYS.size()]
	var image1 = load(choice1.file)
	var key1 = choice1.key
	qte1_instance = QTE1_SCENE.instantiate()
	add_child(qte1_instance)
	qte1_instance.setup(image1, key1)
	qte1_instance.finished.connect(func(success, elapsed): _on_qte1_finished(success, elapsed))
	# Opcional: poner en coordenada específica si necesitas que no se superponga

func _spawn_qte2():
	if game_over:
		return
	if qte2_instance:
		qte2_instance.queue_free()
	var choice2 = IMAGE2_KEYS[randi() % IMAGE2_KEYS.size()]
	var image2 = load(choice2.file)
	var key2 = choice2.key
	qte2_instance = QTE2_SCENE.instantiate()
	add_child(qte2_instance)
	qte2_instance.setup(image2, key2)
	qte2_instance.finished.connect(func(success, elapsed): _on_qte2_finished(success, elapsed))
	# Opcional: poner en coordenada específica si necesitas que no se superponga

func _on_qte1_finished(success: bool, elapsed: float):
	if game_over:
		return
	if success:
		if elapsed < fast_time:
			score += points_per_fast_success
		else:
			score += points_per_success
	else:
		score += points_per_fail
	_update_score()
	if score >= points_to_win:
		_game_win()
	else:
		_spawn_qte1() # Solo renace el QTE1

func _on_qte2_finished(success: bool, elapsed: float):
	if game_over:
		return
	if success:
		if elapsed < fast_time:
			score += points_per_fast_success
		else:
			score += points_per_success
	else:
		score += points_per_fail
	_update_score()
	if score >= points_to_win:
		_game_win()
	else:
		_spawn_qte2() # Solo renace el QTE2

func _update_score():
	score_label.text = "Puntos: %d" % score

func _game_win():
	game_over = true
	if qte1_instance:
		qte1_instance.queue_free()
	if qte2_instance:
		qte2_instance.queue_free()
	#SceneTransitions.change_scene_to_file("res://Level 1/scenes/listo.tscn")
	#AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	#AudioManager.SFXPlayer.play()
