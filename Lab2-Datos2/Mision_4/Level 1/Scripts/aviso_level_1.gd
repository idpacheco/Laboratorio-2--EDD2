extends Control


func _on_next_to_guia_pressed() -> void:
	SceneTransitions.change_scene_to_file("res://Mision_4/Level 1/scenes/indicaciones.tscn")
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()


func _on_back_to_inicio_pressed() -> void:
	SceneTransitions.change_scene_to_file("res://Mision_4Level 1/scenes/inicio_level_1.tscn")
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()
