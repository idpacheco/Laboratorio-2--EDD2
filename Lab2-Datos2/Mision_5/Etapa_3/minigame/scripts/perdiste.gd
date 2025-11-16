extends Control
func _on_retry_pressed() -> void:
	SceneTransitions.change_scene_to_file("res://Mision_5/Etapa_3/minigame/scenes/search.tscn")
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()


func _on_close_pressed() -> void:
	#SceneTransitions.change_scene_to_file("res://Mision_3/Minijuego_Mision3/scenes/fase1_instc.tscn")
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()
