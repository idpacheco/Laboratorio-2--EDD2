extends Control


func _on_next_to_fase_1_inst_pressed() -> void:
	SceneTransitions.change_scene_to_file("res://Mision_3/Minijuego_Mision3/scenes/fase1_instc.tscn")
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()

func _on_skip_pressed() -> void:
	SceneTransitions.change_scene_to_file("res://Mision_3/Minijuego_Mision3/scenes/main_minigame_3.tscn")
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()
