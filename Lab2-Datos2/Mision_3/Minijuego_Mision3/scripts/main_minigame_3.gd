extends Control

const QTE1_SCENE = preload("res://Mision_3/Minijuego_Mision3/scenes/qte1.tscn")
const IMAGE1_KEYS = [
	{ "file": "res://Mision_3/Minijuego_Mision3/assests/cable_fibra.png", "key": KEY_1},
	{ "file": "res://Mision_3/Minijuego_Mision3/assests/chip.png", "key": KEY_2 },
	{ "file": "res://Mision_3/Minijuego_Mision3/assests/conector.png", "key": KEY_3 }
]
const QTE2_SCENE = preload("res://Mision_3/Minijuego_Mision3/scenes/qte_2.tscn")
const IMAGE2_KEYS = [
	{ "file": "res://Mision_3/Minijuego_Mision3/assests/archivo corrupto.png", "key": KEY_U},
	{ "file": "res://Mision_3/Minijuego_Mision3/assests/virus.png", "key": KEY_V },
	{ "file": "res://Mision_3/Minijuego_Mision3/assests/roto.png", "key": KEY_R}
]

@export var points_to_win := 5000
@export var points_to_lose := -900
@export var points_per_success := 300
@export var points_per_fast_success := 350
@export var points_per_fail := -150
@export var fast_time := 0.5

@onready var score_label: Label = %ScoreLabel

@onready var pause_layer = $PauseLayer
@onready var pause_panel = preload("res://Mision_3/Minijuego_Mision3/scenes/pausa.tscn").instantiate()

var score: int = 0
var game_over: bool = false
var qte1_instance = null
var qte2_instance = null

func _ready():
	randomize()
	score = 0
	game_over = false
	_update_score()
	_spawn_qte1()
	_spawn_qte2()
	pause_layer.add_child(pause_panel)
	pause_panel.visible = false

	
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
	# Comprobar victoria / derrota
	if score >= points_to_win:
		_game_win()
	elif score <= points_to_lose:
		_game_lose()
	else:
		_spawn_qte1()

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
	# Comprobar victoria / derrota
	if score >= points_to_win:
		_game_win()
	elif score <= points_to_lose:
		_game_lose()
	else:
		_spawn_qte2()

func _update_score():
	score_label.text = "Puntos: %d" % score

func _game_win():
	game_over = true
	if qte1_instance:
		qte1_instance.queue_free()
	if qte2_instance:
		qte2_instance.queue_free()
	SceneTransitions.change_scene_to_file("res://Mision_3/Minijuego_Mision3/scenes/win.tscn")
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()


func _game_lose():
	game_over = true
	if qte1_instance:
		qte1_instance.queue_free()
	if qte2_instance:
		qte2_instance.queue_free()
	SceneTransitions.change_scene_to_file("res://Mision_3/Minijuego_Mision3/scenes/lose.tscn")
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()

		

func _on_img_button_pressed() -> void:
	print("SIRVE, HAY CLICK LOL")
	if get_tree().paused:
		get_tree().paused = false
		pause_panel.visible = false
	else:
		get_tree().paused = true
		pause_panel.visible = true
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()

func _on_pause_button_pressed() -> void:
	print("SIRVE, HAY CLICK LOL")
	get_tree().paused = !get_tree().paused # Cambia entre pausa y no pausa
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()
