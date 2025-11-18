extends Control



func _on_continue_pressed() -> void:
	SceneTransitions.change_scene_to_file("res://Mision_3/inicio.tscn")
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()
