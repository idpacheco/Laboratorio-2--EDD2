extends Control


func _on_continue_2_pressed() -> void:
	SceneTransitions.change_scene_to_file("res://Mision_2/Scene/fase_1.tscn")
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()
