extends Control


func _on_play_button_pressed() -> void:
	SceneTransitions.change_scene_to_file("res://Level 1/scenes/level_1_main.tscn")
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()

func _on_instrucciones_button_pressed() -> void:
	SceneTransitions.change_scene_to_file("res://Level 1/scenes/aviso_level_1.tscn")
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()
