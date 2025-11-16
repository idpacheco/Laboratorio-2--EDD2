extends Control

const QTE_SCENE = preload("res://Mision_4/Level 1/scenes/QTE.tscn")
const IMAGE_KEYS = [
	{ "file": "res://Mision_4/Level 1/Assets+/Malware.png", "key": KEY_M},
	{ "file": "res://Mision_4/Level 1/Assets+/Phising.png", "key": KEY_P },
	{ "file": "res://Mision_4/Level 1/Assets+/SQL Injection.png", "key": KEY_S },
	{ "file": "res://Mision_4/Level 1/Assets+/Spyware.png", "key": KEY_Y }
]

@export var points_to_win := 1000
@export var points_per_success := 100
@export var points_per_fast_success := 150
@export var points_per_fail := -200
@export var fast_time := 0.5

@onready var score_label: Label = %ScoreLabel

@onready var pause_layer = $PauseLayer
@onready var pause_panel = preload("res://Mision_4/Level 1/scenes/guia_pausa.tscn").instantiate()

var score: int = 0
var game_over: bool = false

func _ready():
	score = 0
	game_over = false
	_update_score()
	_next_qte()
	pause_layer.add_child(pause_panel)
	pause_panel.visible = false

	
func _next_qte():
	if game_over:
		return
	var choice = IMAGE_KEYS[randi() % IMAGE_KEYS.size()]
	var image = load(choice.file)
	var key = choice.key
	var qte = QTE_SCENE.instantiate()
	add_child(qte)
	qte.setup(image, key)
	qte.finished.connect(_on_qte_finished)

func _on_qte_finished(success: bool, elapsed: float):
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
		_next_qte()

func _update_score():
	score_label.text = "Puntos: %d" % score

func _game_win():
	game_over = true
	SceneTransitions.change_scene_to_file("res://Mision_4/Level 1/scenes/listo.tscn")
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()



func _on_img_button_pressed() -> void:
	if get_tree().paused:
		get_tree().paused = false
		pause_panel.visible = false
	else:
		get_tree().paused = true
		pause_panel.visible = true

	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()


func _on_pause_button_pressed() -> void:
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()
	get_tree().paused = !get_tree().paused # Cambia entre pausa y no pausa
