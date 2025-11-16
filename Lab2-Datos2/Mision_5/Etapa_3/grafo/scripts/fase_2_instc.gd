extends Control

func _on_next_to_grafo_pressed() -> void:
	SceneTransitions.change_scene_to_file("res://Mision_3/Mision 3/scenes/main_mision_3.tscn")
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()
