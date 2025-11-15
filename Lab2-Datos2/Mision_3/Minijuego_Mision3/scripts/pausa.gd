extends Control

func _on_back_to_game_pressed() -> void:
	get_tree().paused = false
	queue_free()
	AudioManager.SFXPlayer.stream = preload("res://mainMenu/Assets/Audio/tf2-button-click-hover.mp3")
	AudioManager.SFXPlayer.play()
