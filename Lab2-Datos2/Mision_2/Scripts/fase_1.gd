extends Control

func _on_next_to_img_pressed() -> void:
	SceneTransitions.change_scene_to_file("res://Mision_2/Scene/main_mision_2.tscn")
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()
