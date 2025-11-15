extends Control


func _on_play_game_pressed() -> void:
	SceneTransitions.change_scene_to_file("res://Level 1/scenes/level_1_main.tscn")
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()

func _on_back_to_img_pressed() -> void:
	SceneTransitions.change_scene_to_file("res://Level 1/scenes/img.tscn")
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()
