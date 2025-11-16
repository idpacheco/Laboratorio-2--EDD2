extends Control


func _on_next_to_imag_pressed() -> void:
	SceneTransitions.change_scene_to_file("res://Mision_4/Level 1/scenes/img.tscn")
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()

func _on_back_to_aviso_pressed() -> void:
	SceneTransitions.change_scene_to_file("res://Mision_4/Level 1/scenes/aviso_level_1.tscn")
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()
