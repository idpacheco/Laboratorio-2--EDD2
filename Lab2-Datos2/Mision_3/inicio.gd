extends Control


func _on_play_to_contexto_pressed() -> void:
	SceneTransitions.change_scene_to_file("res://Mision_3/Minijuego_Mision3/scenes/contexto.tscn")
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()
