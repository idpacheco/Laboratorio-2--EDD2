extends Control


func _on_next_to__pressed() -> void:
	#SceneTransitions.change_scene_to_file("res://Mision_3/Mision 3/scenes/winner.tscn")
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()
