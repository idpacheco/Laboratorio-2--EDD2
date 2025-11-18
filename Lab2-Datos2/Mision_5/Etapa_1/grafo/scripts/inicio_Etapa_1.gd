extends Node2D

func _on_play_button_pressed() -> void:
	SceneTransitions.change_scene_to_file("res://Mision_5/Etapa_1/grafo/scenes/contexto.tscn")
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()
