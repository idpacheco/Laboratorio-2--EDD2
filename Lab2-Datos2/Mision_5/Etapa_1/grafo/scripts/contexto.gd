extends Control

@onready var aviso1 = $aviso1
@onready var aviso2 = $aviso2

func _ready():
	# Asegura que las imágenes no estén visibles al inicio
	aviso1.visible = true
	aviso2.visible = false


func _on_continue_pressed() -> void:
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()
	aviso1.visible = false
	aviso2.visible = true


func _on_continue_2_pressed() -> void:
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()
	SceneTransitions.change_scene_to_file("res://Mision_5/Etapa_1/grafo/scenes/help.tscn")
